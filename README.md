# 🛒 Batkhela Marketplace

> **Alibaba Cloud AI Hackathon Pakistan 2026 Submission**  
> *A Production-Ready, Multi-Role Digital Marketplace & Hyper-Local Delivery Platform for Secondary & Rural Cities in Pakistan.*

---

## 📌 1. Project Overview

**Batkhela Marketplace** is an end-to-end multi-role digital commerce ecosystem engineered to bridge local merchants, delivery fleets, customers, and district platform operators into a unified real-time application. 

Built with **Flutter** (Clean Architecture & Monorepo) and designed for high-performance mobile and web environments, it empowers Tier-3 secondary cities (starting with Batkhela, Malakand Division, Khyber Pakhtunkhwa) with modern on-demand retail and logistics capabilities.

---

## 🚨 2. The Problem

In Pakistan's secondary cities and district hubs like Batkhela:
1. **Offline Retail Fragmentation:** Small and medium bazaar merchants (restaurants, bakeries, grocery stores, pharmacies) rely on physical foot traffic and lack digital order management.
2. **Absence of On-Demand Logistics:** Mainstream quick-commerce platforms cater primarily to Tier-1 metropolitan hubs (Karachi, Lahore, Islamabad), leaving regional district markets unserved.
3. **High Latency & Informal Channels:** Customers resort to uncoordinated phone calls, leading to order miscommunication, lack of live delivery tracking, and zero price transparency.
4. **Underutilized Youth Workforce:** Local bike riders lack an organized dispatch system with transparent payouts and GPS-assisted route guidance.

---

## 💡 3. The Solution

Batkhela Marketplace interconnects four distinct user experiences in a single, cohesive ecosystem:

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   🛍️ Customer   │ ───►  │   🏪 Merchant   │ ───►  │    🛵 Rider     │
│   (Mobile App)  │       │  (Vendor Portal)│       │ (Delivery Radar)│
└────────┬────────┘       └────────┬────────┘       └────────┬────────┘
         │                         │                         │
         └─────────────────────────┼─────────────────────────┘
                                   │
                                   ▼
                      ┌─────────────────────────┐
                      │    🛡️ Super Admin       │
                      │  (Web Control Center)   │
                      └─────────────────────────┘
```

1. **Customers:** Browse local bazaar stores, filter by category, place orders, and track deliveries with live GPS route previews.
2. **Vendors / Merchants:** Manage product catalogs, toggle item stock, process incoming orders in real time, and review delivery partner requests.
3. **Delivery Riders:** Receive nearby delivery offers, navigate with localized GPS routing, transition delivery stages, and track transparent earnings.
4. **Super Admin (Web):** Full operational governance — vendor KYC verification, rider onboarding, catalog governance, promotional banners, and regional multi-city expansion toggles.

---

## ✨ 4. Key Features

### 🛍️ Customer Experience (`apps/mobile_app`)
- **Marketplace Browsing:** Discover local bazaar stores, daily promotions, and curated food/grocery items.
- **Real-Time Product Search & Filtering:** Instant search with dynamic category chips (*Shinwari Tikka, Fresh Produce, Bakery, Essentials*).
- **Dynamic Cart & Checkout:** Subtotal, delivery fee calculation, and order placement with cash-on-delivery (COD).
- **Live Order Tracking Sheet Modal:** Real-time route navigation preview, assigned rider telemetry, and step-by-step order progression.
- **Customer Profile & Address Book:** Multiple delivery addresses with default selection.

### 🏪 Vendor Experience (`apps/mobile_app`)
- **Store Operations Dashboard:** Operational KPIs (Today's revenue, active orders, customer rating).
- **Real-Time Orders Queue:** Live order lifecycle actions (*Accept $\rightarrow$ Preparing $\rightarrow$ Ready for Pickup*).
- **Product Catalog Management:** Add/edit products, manage discounted pricing, and toggle in-stock/sold-out status.
- **Business Profile & Hours:** Store operational open/closed toggle with instant customer-facing status updates.
- **Rider Application Review:** Approve or reject local rider onboarding applications directly from the merchant portal.

### 🛵 Rider Experience (`apps/mobile_app`)
- **Delivery Radar & Online Status:** Live toggle to broadcast GPS telemetry and receive nearby dispatch assignments.
- **Dispatch Offer Review:** Rich offer cards displaying pickup store, customer drop-off area, package items, and guaranteed payout.
- **5-Stage Delivery State Machine:**
  $$\text{Accepted} \longrightarrow \text{Arrived at Pickup} \longrightarrow \text{Picked Up} \longrightarrow \text{On The Way} \longrightarrow \text{Delivered}$$
- **Battery-Friendly GPS Telemetry:** Continuous heading, speed, and coordinate tracking with smart distance filters.
- **Earnings & Payout Hub:** Detailed breakdown of base delivery fees, distance bonuses, daily net earnings, and 24/7 emergency helpline.

### 🛡️ Super Admin Web Control Center (`apps/admin_web`)
- **Live Operations Dashboard:** Platform-wide gross merchandise value (GMV), active fleet count, and fulfillment velocity.
- **Vendor KYC & Approval:** Review submitted merchant documents and approve/reject new stores.
- **Rider Onboarding Hub:** Background check verification, vehicle inspection, and fleet activation.
- **Category & Taxonomy Tree:** Create, edit, and organize marketplace categories.
- **Promotions & Homepage Sections:** Toggle promotional banners, featured vendor sections, and seasonal campaigns.
- **Regional Multi-City Expansion:** Toggle new delivery zones (*Batkhela, Thana, Chakdara, Timergara, Dargai*).
- **Platform Fee Governance:** Configure delivery base fees and merchant commission rates.

---

## 🛠️ 5. Technical Highlights

- **Flutter Monorepo Architecture:** Clean code separation into modular layers (`marketplace_core`, `mobile_app`, `admin_web`).
- **Clean Architecture & Repository Pattern:** Strict abstraction between UI presentation layer, domain models, and data repositories.
- **Dual-Engine Data Hub (`MarketplaceDataService`):** Supports seamless runtime switching between **1-Click Offline Demo Mode** and **Real Supabase Cloud Mode**.
- **PostgreSQL & Row Level Security (RLS):** Production-ready database migrations with granular tenant isolation policies.
- **Supabase Storage Integration:** Multi-bucket storage architecture (`user-avatars`, `store-logos`, `store-banners`, `product-images`, `delivery-proofs`) with MIME validation.
- **Supabase Realtime Streams:** Event-driven architecture with automatic reconnection and lifecycle disposal.
- **Pure Dart Haversine Geodesic Engine:** Mathematical distance computation without requiring heavy external geo-plugins:
  $$d = 2R \cdot \arcsin\left(\sqrt{\sin^2\left(\frac{\Delta \phi}{2}\right) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(\frac{\Delta \lambda}{2}\right)}\right)$$
- **Battery-Friendly GPS Telemetry:** Dual-condition throttling ($\ge 10\text{m}$ movement filter OR 30-second heartbeat) preventing battery drain.
- **Stylized Batkhela Vector Map Canvas:** Custom vector painter rendering Batkhela GT Road, Bypass Road, and Swat River without external paid map API dependencies.
- **Google Stitch Design Tokens:** Unified typography, spacing, elevation, and color tokens with native RTL Urdu localization foundation.

---

## 🚀 6. One-Click Demo Mode

To allow hackathon judges to inspect and evaluate the entire application immediately:

> **✨ ZERO-CONFIGURATION DEMO MODE**  
> The application includes a standalone in-memory demo engine populated with realistic Batkhela Bazaar data.  
> **No API keys, no cloud credentials, and no database setup are required to test all features.**

- **Realistic Merchant Datasets:** Pre-loaded with authentic Batkhela stores (*Shinwari Tikka & Karahi, Malakand Sweets & Bakers, Swat Valley Mart, Khyber Pharmacy*).
- **Simulated GPS Coordinates:** Real-world waypoints along Main GT Road, Clock Tower Chowk, and Bypass Road.
- **Instant Role Switcher:** Switch between Customer, Vendor, Rider, and Super Admin in one tap.

---

## 📂 7. Project Structure

```
BatkhelaMarketplace/
├── packages/
│   └── marketplace_core/          # Shared Core Domain & Data Layer
│       ├── lib/src/models/         # User, Vendor, Order, Delivery, Location models
│       ├── lib/src/repositories/   # Repository contracts (Demo & Supabase implementations)
│       ├── lib/src/services/       # Auth, Data Hub, Realtime, Location Services
│       ├── lib/src/theme/          # Google Stitch Design System tokens
│       └── test/                   # 59 automated unit & domain tests
├── apps/
│   ├── mobile_app/                 # Flutter Mobile App (Android & iOS)
│   │   ├── lib/src/screens/auth/   # Phone OTP Login & Role Selector
│   │   ├── lib/src/screens/customer/ # Customer Marketplace Screens
│   │   ├── lib/src/screens/vendor/   # Vendor Dashboard & Catalog Management
│   │   ├── lib/src/screens/rider/    # Rider Telemetry Radar & Deliveries
│   │   ├── lib/src/widgets/        # Stylized Map Canvas & Shared Components
│   │   └── test/                   # 26 automated widget & integration tests
│   └── admin_web/                  # Flutter Web Super Admin Control Center
│       ├── lib/src/screens/admin/  # 9-Domain Super Admin Management Views
│       └── test/                   # 10 automated admin dashboard tests
├── supabase/
│   └── migrations/                 # PostgreSQL schemas, RLS policies, Storage buckets
├── .env.example                    # Environment variable template (no secrets committed)
└── README.md                       # Project documentation & Hackathon pitch
```

---

## 💻 8. How to Run

### Prerequisites
- **Flutter SDK:** `>= 3.24.0` (Dart `>= 3.5.0`)
- **Android SDK:** API 34+ (for Android APK / Emulator)
- **Web Browser:** Google Chrome / Microsoft Edge (for Web Admin)

### Step-by-Step Setup

```bash
# 1. Clone the repository
git clone https://github.com/Shani14814/BatkhelaMarketplace.git
cd BatkhelaMarketplace

# 2. Run Automated Tests across all modules
cd packages/marketplace_core && flutter test
cd ../../apps/mobile_app && flutter test
cd ../admin_web && flutter test

# 3. Launch the Multi-Role Mobile Application (Default: Demo Mode)
cd ../mobile_app
flutter run -d android

# 4. Launch the Super Admin Web Dashboard
cd ../admin_web
flutter run -d chrome
```

---

## 📱 9. APK Demo

A standalone Android APK is generated and available for direct installation:

* **APK Location:** `apps/mobile_app/build/app/outputs/flutter-apk/app-release.apk` (or `app-debug.apk`)
* **Default Launch:** Launches into **Demo Testing Mode** with the 1-Click Role Switcher.
* **Requirements:** Any Android device running Android 8.0+ (API 26+). No login credentials required.

---

## 🌟 10. Hackathon Impact

| Dimension | Impact & Value Proposition |
| :--- | :--- |
| **Local Economic Empowerment** | Enables grassroots bazaar merchants in Batkhela to establish a digital storefront with zero upfront infrastructure investment. |
| **Youth Gig Employment** | Creates structured, flexible income opportunities for local motorcycle riders with transparent delivery fare calculations. |
| **Consumer Access** | Delivers price transparency, door-step delivery, and real-time tracking to households in secondary cities. |
| **Scalable Blueprint** | Designed as a replicable template for hundreds of Tier-2 and Tier-3 secondary cities across Pakistan (*Timergara, Swat, Mardan, Kohat, Abbottabad*). |

---

## 📋 11. Judge Quick Test Guide

Judges can evaluate the entire marketplace workflow in **under 3 minutes**:

1. **Open the Mobile App:**
   * On launch, tap **"Switch to Demo Testing Mode (Role Selector)"**.
2. **Test as Customer:**
   * Tap **"Customer (Bazaar Shopper)"**.
   * Browse products, tap **"Add to Cart"**, and confirm checkout.
   * Go to **"Orders"** tab $\rightarrow$ Tap **"Track Live Rider & Route"** to see live route navigation.
3. **Test as Vendor:**
   * Switch role to **"Vendor (Store Manager)"**.
   * View live KPIs, toggle store open/closed, manage product catalog stock, and review incoming orders.
4. **Test as Rider:**
   * Switch role to **"Rider (Delivery Fleet)"**.
   * Toggle **Online Radar** $\rightarrow$ Observe live GPS telemetry broadcasting.
   * Open the active delivery and progress through the 5 lifecycle stages (*Arrived at Pickup $\rightarrow$ Picked Up $\rightarrow$ Delivered*).
5. **Test Super Admin (Web):**
   * Launch `apps/admin_web` in Chrome $\rightarrow$ Tap **"1-Click Super Admin Demo Login"**.
   * Explore the 9 operations management domains including Vendor KYC approvals and multi-city geographic expansion toggles.

---

## 📄 License & Attribution

Developed for the **Alibaba Cloud AI Hackathon Pakistan 2026** by team *Batkhela Marketplace*.
Distributed under the MIT License.
