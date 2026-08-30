# Batkhela Marketplace

A production-ready, multi-role digital marketplace platform tailored for Batkhela.

## Architecture

- **`packages/marketplace_core`**: Shared Dart package containing domain models, Supabase API client, design system & typography (with Urdu RTL localization support), and utility constants.
- **`apps/mobile_app`**: Flutter Mobile app for Android & iOS delivering role-based experiences:
  - **Customer**: Storefront, product discovery, dynamic cart, live order tracking.
  - **Vendor**: Store catalog management, real-time incoming order dashboard, sales metrics.
  - **Rider**: Delivery radar, route mapping via Google Maps, order pickup/drop-off confirmation.
- **`apps/admin_web`**: Flutter Web responsive Super Admin Dashboard for operations, vendor/rider KYC verification, live operations tracking, and financial reconciliation.
- **`supabase/migrations`**: PostgreSQL relational schema, Row Level Security (RLS) policies, and Supabase Storage bucket configurations.

## Quick Start

### 1. Prerequisites
- Flutter SDK `^3.47.0` (Dart `^3.13.0`)
- Android SDK 36 (for Mobile App)
- Google Chrome / Edge (for Web Admin)

### 2. Setup
```bash
# In packages/marketplace_core
flutter pub get

# In apps/mobile_app
flutter pub get
flutter run -d android

# In apps/admin_web
flutter pub get
flutter run -d chrome
```
