# Tessera — PROJECT_SUMMARY.md

> **Last updated:** June 2026  
> **Source of truth:** `lib/`, `pubspec.yaml`, `assets/`  
> **Purpose:** Handoff document so another developer can continue without losing context.

---

## Project Overview

**Tessera** is a Flutter mobile fashion e-commerce app (Azerbaijani UI, **₼** pricing). It is a **UI-first prototype** modeled after modern retail apps (Zara / AboutYou / H&M). There is **no backend**, **no persistence**, and **no automated tests** yet.

| Item | Value |
|------|-------|
| Package | `tessera` |
| Version | `1.0.0+1` |
| Flutter SDK | `^3.8.1` |
| Dart files | ~98 under `lib/` |
| Maturity | Prototype — not production-ready |

---

## Architecture

### Pattern
- **Two-module split:** `lib/screens/` (app entry, auth) + `lib/tarz/` (commerce UI)
- **Navigation:** `MaterialApp.onGenerateRoute` → `AppRoutes.generateRoute`
- **Tab shell:** `TarzHomeScreen` renders 5 bottom-nav tabs inline; cart/search/PLP/PDP are pushed routes
- **Data:** Mock-first — static lists in `TarzMockCatalog` + asset path constants; no repository/service layer
- **UI organization:** Feature folders under `lib/tarz/widgets/` (`home/`, `catalogue/`, `listing/`, `cart/`, `filter/`, `product_details/`)

### Tech stack
| Layer | Choice |
|-------|--------|
| UI | Material 3 |
| State | `ChangeNotifier` singletons (no Provider/Riverpod/Bloc) |
| HTTP | None |
| Persistence | None |
| i18n | Hardcoded Azerbaijani strings |

### Design tokens
`lib/tarz/theme/` — `tarz_colors`, `tarz_spacing`, `tarz_text_styles`, `tarz_breakpoints`, `tarz_home_layout`

### Key architectural decisions
1. **`tarz/` prefix** — all commerce code isolated from auth/splash shell
2. **Hanger nav icon = Kombinlərim** (not cart)
3. **Cart via pushed route** `/cart` from header icons
4. **Default tab = Home** (index 2) on launch
5. **Splash bypasses login** — intentional for UI development
6. **Unknown routes → HomeScreen**
7. **Typed route args** — `ProductListingArgs`, `ProductDetailsArgs` (not raw Maps)

### Navigation flow
```
Splash (3s) → /home → TarzHomeScreen

Tab shell (_navIndex):
  0 → Catalogue    1 → Kombinlərim    2 → Home    3 → Wishlist    4 → Profile

Pushed routes:
  /search, /filter, /listing/products, /product/details, /cart,
  /notifications, /login, /register
```

---

## Folder Structure

```
tessera/
├── lib/
│   ├── main.dart                         # ListenableBuilder + MaterialApp
│   ├── routes/app_routes.dart            # All named routes + arg classes
│   ├── screens/                          # App shell (4 files)
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── home_screen.dart              # → TarzHomeScreen
│   ├── widgets/                          # Shared auth UI
│   │   ├── custom_button.dart            # Unused
│   │   ├── custom_textfield.dart         # Unused
│   │   └── register/
│   └── tarz/                             # Primary commerce module
│       ├── tarz_home_screen.dart         # Tab shell + home scroll
│       ├── cart/                         # Controller + price utils
│       ├── wishlist/                     # Wishlist controller
│       ├── data/                         # Mocks + asset constants
│       ├── models/                       # Product, cart, store, catalogue models
│       ├── theme/                        # Colors, spacing, layout constants
│       ├── screens/                      # 10 commerce screens
│       └── widgets/                      # Feature widgets + bottom nav
├── assets/
│   ├── splashscreen.png, icon/tesicon.png
│   ├── banners/                        # Hero, category photos, brands_yerli.png
│   ├── nav/                              # catalog, hanger, home icons
│   ├── catalogue/                        # Uşaq kataloqu Figma banners (3)
│   ├── products/                         # nike_v5_rnr.png, green_cardigan.png
│   └── stores/                           # Legacy PNGs (unused in current UI)
├── pubspec.yaml
├── PROJECT_SUMMARY.md
└── README.md                             # Generic Flutter template (not project docs)
```

**Missing layers (planned):** `lib/services/`, `lib/repositories/`, `lib/config/`, `.env`

---

## Implemented Screens

### App-level (`lib/screens/`)

| Screen | Route | Status |
|--------|-------|--------|
| Splash | `/splash` | 3s image → `/home` (skips auth) |
| Login | `/login` | UI + social placeholders; bottom nav to home tabs |
| Register | `/register` | Figma-style form; no API |
| Home wrapper | `/home` | Renders `TarzHomeScreen(initialNavIndex?)` |

### Commerce (`lib/tarz/screens/`)

| Screen | Access | Status |
|--------|--------|--------|
| `TarzCatalogueScreen` | Nav tab 0 | Gender selector, category list, uşaq banners |
| `TarzOutfitsScreen` | Nav tab 1 | **Kombinlərim** — empty placeholder |
| Home scroll | Nav tab 2 | Hero, Yenilər, Kateqoriyalar, Brendlər, Mağazalar |
| `TarzWishlistScreen` | Nav tab 3 | 2-column grid or empty state |
| `TarzProfileScreen` | Nav tab 4 | Menu + login/register CTAs |
| `TarzCategoryListingScreen` | `/listing/products` | PLP — grid, sort, filter bar |
| `ProductDetailsScreen` | `/product/details` | PDP — gallery, size, cart, wishlist |
| `TarzCartScreen` | `/cart` | Items, promo UI, gift wrap, checkout stub |
| `TarzFilterScreen` | `/filter` | Full filter UI (isolated from PLP) |
| `TarzSearchScreen` | `/search` | Search field; no results |
| `TarzNotificationsScreen` | `/notifications` | Empty state |

### Bottom navigation

| Index | Icon | Destination |
|-------|------|-------------|
| 0 | `catalog_icon.png` | Catalogue |
| 1 | `hanger_icon.png` | Kombinlərim |
| 2 | `home_icon.png` (center circle) | Home |
| 3 | `favorite_border` | Wishlist |
| 4 | `person_outline` | Profile |

---

## Features Already Completed

### App shell
- [x] Splash screen with asset image
- [x] Named routing with typed arguments
- [x] Global cart badge rebuild via `ListenableBuilder`
- [x] App launcher icons from `tesicon.png`

### Home screen
- [x] Search header (search, notifications, cart icon)
- [x] Gender segmented tabs (Qadın / Kişi / Uşaq)
- [x] Hero banner — single Figma `slider_banner.png`
- [x] **Yenilər** — 2-column product grid (Nike V5 RNR, kardiqan)
- [x] **AI outfit banner** — CTA (toast placeholder)
- [x] **Kateqoriyalar** — 2×2 split cards (colored label + photo)
- [x] **Brendlər** — horizontal scroll Figma `brands_yerli.png` (470×283)
- [x] **Mağazalar** — 2-row horizontal scroll; white cards, black text labels
- [x] Side drawer with gender + category labels

### Catalogue
- [x] Gender selector synced with home
- [x] Animated underline category list (Qadın/Kişi)
- [x] Uşaq mode — 3 full-width Figma banners (Körpələr, Oğlanlar, Qızlar)
- [x] Category tap → PLP with mock products
- [x] Search bar + cart icon

### Shopping flow
- [x] PLP — 2-column grid, client-side sort, category/sort bottom sheets
- [x] PLP shimmer loading + empty state
- [x] PDP — image gallery, size selector (XS–XL), price, reviews (mock)
- [x] Add to cart from PDP (size-aware line items)
- [x] Wishlist hearts on PLP and home (synced)
- [x] Related products horizontal scroll on PDP

### Cart
- [x] Add / remove / quantity increment/decrement
- [x] Summary: subtotal, discount, gift wrap (+10₼), total
- [x] Promo code expandable section (UI only)
- [x] Sticky checkout button (no payment flow)
- [x] Empty cart state

### Filter
- [x] Full filter screen: seasons, price range, categories, colors, sizes, brands
- [x] Expandable sections, chips, color dots

### Profile & auth
- [x] Login / Register UI with social button placeholders
- [x] Profile menu: Sifarişlər, Seçilmişlər, Kombinlərim, Bildirişlər, Dil, Kömək
- [x] Profile shortcuts → wishlist tab, outfits tab, notifications route

### Notifications
- [x] Notifications page with empty state
- [x] Opened from home bell icon or profile menu

### Mock data & assets
- [x] Centralized `TarzMockCatalog` with listing/home/catalogue data
- [x] Asset constant classes (`TarzBannerAssets`, `TarzProductAssets`, etc.)
- [x] All product mocks alternate 2 product images

---

## State Management

| Domain | Class | Pattern |
|--------|-------|---------|
| Cart | `TarzCartController` | Singleton `ChangeNotifier` |
| Wishlist | `TarzWishlistController` | Singleton `ChangeNotifier` |
| App-wide rebuild | `ListenableBuilder` in `main.dart` | Merges both controllers |
| Screen UI | `StatefulWidget` + `setState` | PLP sort, filter form, PDP size, cart toggles |
| Route data | `ProductListingArgs`, `ProductDetailsArgs` | Passed via `Navigator` |

### Cart controller (`TarzCartController.instance`)
- `addFromProduct(product, size)` — composite ID `{productId}_{size}`
- `updateQuantity`, `incrementQuantity`, `decrementQuantity`, `removeItem`, `clear`
- `buildSummary(includeGiftWrap)` — calculates totals
- `totalQuantity` — cart badge count

### Wishlist controller (`TarzWishlistController.instance`)
- Lazy seeds 4 items from `homeNewProductsGrid()` on first access
- `add`, `remove`, `toggle`, `contains`, `ensureLoaded`

**Not used:** Provider, Riverpod, Bloc, GetX, dependency injection.

---

## Backend Integration Status

**Status: Not integrated.**

| Area | Current | Needed |
|------|---------|--------|
| Products | `TarzMockCatalog` | `GET /products`, `GET /products/:id` |
| Categories | Hardcoded lists | `GET /categories?gender=` |
| Stores | `StoreChipsSection.mockStores()` | `GET /stores` |
| Cart | In-memory controller | CRUD cart API |
| Wishlist | In-memory controller | Wishlist API |
| Auth | UI only | Login/register/token endpoints |
| Search | Toast on submit | `GET /search?q=` |
| Notifications | Empty state | `GET /notifications` |
| Orders | Toast | `GET /orders` |
| Outfits | Placeholder | `GET/POST /outfits` |
| Checkout | Button stub | Payment API |

### Missing infrastructure
- No `http` / `dio` in `pubspec.yaml`
- No `.env` or API config
- No `lib/services/` or `lib/repositories/`
- No token storage (`flutter_secure_storage` / `shared_preferences`)
- No network image caching (`cached_network_image`)

### Suggested future structure
```
lib/config/api_config.dart
lib/services/api_client.dart
lib/services/auth_service.dart
lib/repositories/product_repository.dart
lib/repositories/cart_repository.dart
```

---

## Pending Tasks

### High priority
1. Backend API integration (products, auth, cart, wishlist, search)
2. Auth persistence + splash token check
3. Login / Register API wiring
4. Filter → PLP — return filter state and apply to listing
5. Search results with API
6. Checkout / payment flow
7. Persist cart & wishlist (local or API sync)
8. **Kombinlərim** — real screen + API (currently placeholder)
9. **AI outfit** route and flow

### Medium priority
10. Repository layer replacing direct `TarzMockCatalog` usage
11. Gender tab → reload home/catalogue from API
12. Store / category / brand card taps → real listing pages
13. Replace `README.md` with project-specific docs
14. Fix or replace `assets/nav/home_icon.png` (~199 bytes, may be corrupt)
15. Add proper Flutter `launch.json` for mobile (current is Chrome stub)
16. Wire profile menu items (Sifarişlər, Dil, Kömək)

### Low priority
17. Remove/archive ~20 legacy unused widgets
18. Remove unused `assets/stores/` PNGs or wire logo cards
19. Add widget/integration tests (`test/` directory missing)
20. CI/CD pipeline
21. i18n framework for multi-language support

### TODO markers in code
Search `TODO:` in `lib/` for API integration points:
- `tarz_home_screen.dart` — gender tab refresh, AI outfit route
- `tarz_mock_catalog.dart` — replace with repository
- `store_chips_section.dart`, `category_grid_section.dart` — API mocks
- `children_catalogue_block.dart` — subcategory routes
- `tarz_wishlist_controller.dart` — API wishlist

---

## Known Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| No API / persistence | **High** | All cart/wishlist data lost on restart |
| Auth bypassed at splash | **High** | Intentional for UI dev |
| Filter doesn't affect PLP | **Medium** | Filter screen is isolated |
| Search has no results | **Medium** | Submit shows SnackBar only |
| Kombinlərim placeholder | **Medium** | Empty state only |
| No test suite | **Medium** | `test/` directory does not exist |
| Notifications always empty | **Low** | By design until API |
| `home_icon.png` suspect | **Low** | 199 bytes; may render incorrectly |
| PDP demo title hack | **Low** | `Nike V5 RNR` → `Brown Check Asymmetric Wrap Skirt` in cart |
| Only 2 product images | **Low** | All mocks reuse same 2 PNGs |
| Legacy widget clutter | **Low** | ~20 unwired `tarz_*.dart` files remain |
| `assets/stores/` unused | **Low** | Mağazalar uses text labels, not PNG logos |
| `README.md` generic | **Low** | Not updated; use this file instead |
| `.vscode/launch.json` | **Low** | Chrome stub, not Flutter mobile config |

### Previously fixed
- **Brendlər crash** — negative `ListView` padding caused Flutter assertion; fixed with proper symmetric padding and width-based peek.

---

## Build & Run

```bash
cd tessera
flutter pub get
flutter analyze lib
flutter run
```

**Entry:** `lib/main.dart` → `initialRoute: AppRoutes.splash`

**Regenerate icons:**
```bash
dart run flutter_launcher_icons
```

---

## Key Files Reference

| Task | File |
|------|------|
| App entry | `lib/main.dart` |
| Routes | `lib/routes/app_routes.dart` |
| Tab shell | `lib/tarz/tarz_home_screen.dart` |
| Bottom nav | `lib/tarz/widgets/tarz_bottom_navigation.dart` |
| Mock data | `lib/tarz/data/tarz_mock_catalog.dart` |
| Cart logic | `lib/tarz/cart/tarz_cart_controller.dart` |
| Wishlist | `lib/tarz/wishlist/tarz_wishlist_controller.dart` |
| PLP | `lib/tarz/screens/tarz_category_listing_screen.dart` |
| PDP | `lib/tarz/screens/product_details_screen.dart` |
| Layout constants | `lib/tarz/theme/tarz_home_layout.dart` |

---

## Conventions

- UI strings in **Azerbaijani**
- Currency displayed as **₼** via `TarzPriceUtils`
- Unimplemented actions use **SnackBar toasts**
- Figma exports copied to `assets/`; dimensions in `TarzHomeLayout`
- Do not redesign existing UI unless explicitly requested
- Update this file after major features, navigation, or API changes

---

*Maintained manually. Last full codebase review: June 2026.*
