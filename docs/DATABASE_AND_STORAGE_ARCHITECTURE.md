# Batkhela Marketplace — Database & Storage Architecture Guide

This document outlines the complete PostgreSQL database schema, Row Level Security (RLS) policies, security triggers, and Storage Bucket configurations for the **Batkhela Marketplace** backend (Supabase).

---

## 1. Database Architecture Overview

```
                                  auth.users
                                      │
                                      ▼
                               public.profiles ──────────────────────────┐
                                      │                                  │
         ┌────────────────────────────┼────────────────────────────┐     │
         ▼                            ▼                            ▼     ▼
  public.vendors             public.rider_profiles       customer_addresses
         │                            │
   ┌─────┴──────────────┐             │
   ▼                    ▼             ▼
vendor_categories  products      rider_earnings
   │                    │             │
   └──────────┬─────────┘             │
              ▼                       ▼
         public.orders ────────▶ deliveries ──▶ rider_locations
              │                       │
              ▼                       ▼
      public.order_items      order_status_logs
```

---

## 2. Table Catalog

| Table | Description | Primary Key / Relations |
|---|---|---|
| `public.profiles` | User identity records (customers, vendors, riders, admins) | `id REFERENCES auth.users(id)` |
| `public.customer_addresses` | Multiple saved addresses per customer with coordinates | `id`, `customer_id REFERENCES profiles(id)` |
| `public.vendors` | Marketplace vendor profiles, commission, location, open status | `id REFERENCES profiles(id)` |
| `public.vendor_categories` | Store-specific menu/item categories | `id`, `vendor_id REFERENCES vendors(id)` |
| `public.marketplace_categories` | Global top-level marketplace catalog (6 primary categories) | `id`, `slug UNIQUE` |
| `public.products` | Items & goods sold by vendors with prices, discounts, stock | `id`, `vendor_id REFERENCES vendors(id)` |
| `public.vendor_operating_hours` | Vendor opening and closing schedule per day of week | `id`, `vendor_id REFERENCES vendors(id)` |
| `public.orders` | Customer marketplace orders with server-validated totals | `id`, `customer_id`, `vendor_id` |
| `public.order_items` | Individual line items within an order | `id`, `order_id REFERENCES orders(id)` |
| `public.order_status_logs` | Immutable audit log of order status transitions | `id`, `order_id REFERENCES orders(id)` |
| `public.deliveries` | Delivery dispatch tasks assigned to riders | `id`, `order_id`, `rider_id` |
| `public.rider_profiles` | Rider verification, KYC, CNIC, and license credentials | `id REFERENCES profiles(id)` |
| `public.rider_locations` | Real-time GPS telemetry node for live tracking | `rider_id REFERENCES profiles(id)` |
| `public.rider_earnings` | Earnings, tip, fuel allowance, and payout ledger | `id`, `rider_id`, `delivery_id` |
| `public.vendor_rider_contracts` | Agreements between specific vendors and delivery riders | `id`, `vendor_id`, `rider_id` |
| `public.store_reviews` | Customer ratings and reviews for stores with vendor replies | `id`, `customer_id`, `vendor_id` |
| `public.promotions` | Dynamic promotional campaigns and hero banners | `id`, `is_active`, `display_order` |
| `public.service_cities` | Regional multi-city expansion boundaries and radii | `id`, `slug UNIQUE`, `is_active` |
| `public.platform_settings` | Configurable JSON key-value store for platform rules | `id`, `key UNIQUE` |

---

## 3. Security Decisions & RLS Hardening

### 🔒 1. Rider Live GPS Privacy Protection
- **Vulnerability Addressed:** Previously, rider locations were accessible publicly to anyone.
- **Hardened Policy:** SELECT access to `rider_locations` is restricted to:
  1. System Admins (`public.is_admin(auth.uid())`)
  2. The Rider themselves (`auth.uid() = rider_id`)
  3. The Customer who placed an active order currently assigned to that rider (`deliveries.status IN ('assigned', 'picked_up')`)
  4. The Vendor fulfilling the order currently assigned to that rider.

### 🛡️ 2. Privilege Escalation Prevention
- **Trigger:** `public.prevent_role_escalation()` on `public.profiles`.
- **Enforcement:** If a client attempts to modify `role` (e.g. escalating from `'customer'` to `'admin'` or `'super_admin'`), the update is rejected with an exception unless the actor already holds verified admin privileges (`public.is_admin(auth.uid())`).
- **Signup Default:** `public.handle_new_user()` defaults every newly authenticated user to `'customer'`.

### 💰 3. Financial Integrity & Order Total Validation
- **Trigger:** `public.validate_order_totals()` on `public.orders`.
- **Enforcement:** The database guarantees `total_amount = subtotal + delivery_fee + platform_fee` and verifies that all fee components are non-negative, preventing client-side price tampering.

---

## 4. Storage Architecture (Supabase Storage Buckets)

| Bucket Name | Access Level | Permitted File Types | Max Size | Read Policy | Write Policy |
|---|---|---|---|---|---|
| `store-logos` | Public Read | `image/png, image/jpeg, image/webp` | 5 MB | Public (`TRUE`) | Authenticated Vendor (`auth.uid() = vendor_id`) & Admins |
| `store-banners` | Public Read | `image/png, image/jpeg, image/webp` | 8 MB | Public (`TRUE`) | Authenticated Vendor (`auth.uid() = vendor_id`) & Admins |
| `product-images` | Public Read | `image/png, image/jpeg, image/webp` | 5 MB | Public (`TRUE`) | Authenticated Vendor (`auth.uid() = vendor_id`) & Admins |
| `user-avatars` | Public Read | `image/png, image/jpeg, image/webp` | 4 MB | Public (`TRUE`) | Authenticated Owner (`(storage.foldername(name))[1] = auth.uid()::text`) |
| `delivery-proofs` | Private Read | `image/png, image/jpeg, image/webp` | 10 MB | Assigned Rider, Customer, Vendor, & Admins | Authenticated Rider (`auth.uid() = rider_id`) |

---

## 5. Migrations Applied

1. [`supabase/migrations/20260830000001_initial_marketplace_schema.sql`](file:///D:/Projects/BatkhelaMarketplace/supabase/migrations/20260830000001_initial_marketplace_schema.sql)
   - Initial foundational tables and base enums.
2. [`supabase/migrations/20260901000001_complete_marketplace_schema.sql`](file:///D:/Projects/BatkhelaMarketplace/supabase/migrations/20260901000001_complete_marketplace_schema.sql)
   - Production database expansion, KYC rider profiles, order audit logs, GPS location privacy fix, escalation prevention triggers, order verification triggers, and Batkhela initial seeds.
