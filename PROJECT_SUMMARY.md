# Tessera — PROJECT_SUMMARY.md

> **Last updated:** June 2026  
> **Purpose:** Handoff document for continuing development in a new Cursor session or by another developer.  
> **Source of truth:** `lib/`, `pubspec.yaml`, `assets/` — not this file alone.

---

## Project Overview

**Tessera** is a Flutter mobile fashion e-commerce prototype targeting the Azerbaijani market. The UI is modeled after modern retail apps (Zara / AboutYou / H&M style) with Azerbaijani copy and **₼ (AZN)** pricing.

| Attribute | Value |
|-----------|-------|
| **Package name** | `tessera` |
| **Version** | `1.0.0+1` |
| **Flutter SDK** | `^3.8.1` |
| **Locale / copy** | Azerbaijani |
| **Currency display** | `₼` via `TarzPriceUtils` |
| **Maturity** | UI-first prototype — **not production-ready** |
| **Backend** | Not integrated |
| **Auth** | UI only; splash bypasses login |
| **Persistence** | None (cart & wishlist in-memory only) |

### What works today
- Full shopping UI flow: home → catalogue → PLP → PDP → cart
- Bottom navigation shell with 5 tabs
- Mock product data, local assets, Figma-aligned sections
- In-memory cart and wishlist with reactive UI updates

### What does not work yet
- Real API, authentication, checkout, search results, filter application, data persistence

---

## Folder Structure

```
tessera/
├── android/                          # Android platform project
├── ios/                              # iOS platform project
├── assets/
│   ├── splashscreen.png
│   ├── icon/tesicon.png              # App launcher icon source
│   ├── banners/                      # Hero, category, brand banners
│   ├── nav/                          # Bottom nav PNG icons
│   ├── stores/                       # Legacy store logo PNGs (unused in current UI)
│   ├── catalogue/                    # Uşaq kataloqu full-width banners
│   └── products/                     # Product card images (2 images, reused everywhere)
├── lib/
│   ├── main.dart                     # App entry, ListenableBuilder for cart/wishlist
│   ├── routes/
│   │   └── app_routes.dart           # Named routes + ProductListingArgs, ProductDetailsArgs
│   ├── screens/                      # App-level screens (splash, auth, home wrapper)
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── home_screen.dart          # Thin wrapper → TarzHomeScreen
│   ├── widgets/                      # Shared auth UI components
│   │   ├── custom_button.dart
│   │   ├── custom_textfield.dart
│   │   └── register/
│   └── tarz/                         # Commerce UI module (primary codebase)
│       ├── tarz_home_screen.dart     # Tab shell + home scroll content
│       ├── cart/
│       │   ├── tarz_cart_controller.dart
│       │   └── tarz_price_utils.dart
│       ├── wishlist/
│       │   └── tarz_wishlist_controller.dart
│       ├── data/                     # Mock data + asset path constants
│       │   ├── tarz_mock_catalog.dart
│       │   ├── tarz_mock_cart.dart   # Legacy; not used at runtime
│       │   ├── tarz_banner_assets.dart
│       │   ├── tarz_catalogue_assets.dart
│       │   ├── tarz_nav_assets.dart
│       │   ├── tarz_store_assets.dart
│       │   └── tarz_product_assets.dart
│       ├── models/
│       │   ├── tarz_product_preview.dart
│       │   ├── tarz_cart_item.dart
│       │   ├── tarz_store_preview.dart
│       │   └── tarz_children_catalogue_block.dart
│       ├── theme/
│       │   ├── tarz_colors.dart
│       │   ├── tarz_spacing.dart
│       │   ├── tarz_text_styles.dart
│       │   ├── tarz_breakpoints.dart
│       │   └── tarz_home_layout.dart
│       ├── screens/
│       │   ├── tarz_catalogue_screen.dart
│       │   ├── tarz_outfits_screen.dart
│       │   ├── tarz_wishlist_screen.dart
│       │   ├── tarz_profile_screen.dart
│       │   ├── tarz_notifications_screen.dart
│       │   ├── tarz_category_listing_screen.dart   # PLP
│       │   ├── product_details_screen.dart         # PDP
│       │   ├── tarz_cart_screen.dart
│       │   ├── tarz_filter_screen.dart
│       │   └── tarz_search_screen.dart
│       └── widgets/
│           ├── home/                 # Home sections (Yenilər, Kateqoriyalar, Brendlər, Mağazalar…)
│           ├── catalogue/
│           ├── listing/              # plp_* widgets
│           ├── cart/
│           ├── filter/
│           ├── product_details/
│           └── tarz_bottom_navigation.dart
├── pubspec.yaml
├── analysis_options.yaml
├── PROJECT_SUMMARY.md
└── README.md                         # ⚠ Has unresolved git merge conflict
```

**~98 Dart files** under `lib/`.  
**No** `lib/services/`, `lib/repositories/`, `lib/config/`, or `.env` files exist.

---

## Architecture and Patterns

### Module split
| Layer | Location | Responsibility |
|-------|----------|----------------|
| App shell | `lib/screens/` | Splash, login/register, home route wrapper |
| Commerce UI | `lib/tarz/` | All shopping UX — screens, widgets, mock data, controllers |
| Routing | `lib/routes/app_routes.dart` | Central `onGenerateRoute` switch |
| Shared auth widgets | `lib/widgets/` | Reusable login/register fields and buttons |

### Navigation pattern
- **Named routes only** via `MaterialApp.onGenerateRoute`
- **Tab shell** (`TarzHomeScreen`): catalogue, outfits, home, wishlist, profile rendered inline by `_navIndex`
- **Pushed routes**: search, filter, PLP, PDP, cart, notifications, login, register
- **Unknown routes** fall back to `HomeScreen`

### Data pattern (mock-first)
- Static mock lists in `TarzMockCatalog`
- Asset paths in dedicated `*Assets` classes
- No repository / service abstraction yet — designed to swap mocks for API later without rewriting widgets

### UI pattern
- Feature-folder widgets (`home/`, `listing/`, `cart/`, etc.)
- Figma layout constants in `TarzHomeLayout` (store cards, brand banner dimensions)
- Responsive max-width via `TarzBreakpoints.contentMaxWidth()`
- `CustomScrollView` + slivers on home; `LayoutBuilder` for grid sizing

### Legacy / unused widgets (still in repo)
These older components are **not wired** into the current home flow but remain in the codebase:
- `tarz_home_carousel_section.dart`
- `tarz_hero_banner.dart`
- `tarz_home_brands_section.dart`
- `tarz_home_categories_section.dart`
- `tarz_product_grid.dart`, `tarz_product_horizontal_list.dart`
- Various `tarz_*` section widgets from earlier iterations

---

## State Management

| State domain | Implementation | Access |
|--------------|----------------|--------|
| **Cart** | `TarzCartController extends ChangeNotifier` | `TarzCartController.instance` singleton |
| **Wishlist** | `TarzWishlistController extends ChangeNotifier` | `TarzWishlistController.instance` singleton |
| **App rebuild** | `ListenableBuilder` in `main.dart` | Merges both controllers |
| **Screen-local UI** | `StatefulWidget` + `setState` | Per-screen (PLP sort, filter form, PDP size, etc.) |
| **Route arguments** | `ProductListingArgs`, `ProductDetailsArgs` | Passed via `Navigator.pushNamed` |

**Not used:** Provider, Riverpod, Bloc, GetX, or any DI framework.

### Cart controller capabilities
- Add from PDP with size (`addFromProduct`)
- Quantity increment/decrement, remove, clear
- Summary calculation: subtotal, discount, gift wrap (+10₼), shipping (0), total
- `totalQuantity` for cart badge

### Wishlist controller capabilities
- Lazy seed from first 4 `homeNewProductsGrid()` items on first access
- `add`, `remove`, `toggle`, `contains`
- Used by PLP hearts, home Yenilər hearts, wishlist tab

---

## Implemented Screens and Features

### App entry & auth
| Screen | File | Status |
|--------|------|--------|
| Splash | `splash_screen.dart` | 3s timer → `/home` (login skipped) |
| Login | `login_screen.dart` | UI complete; no API; bottom nav to switch tabs |
| Register | `register_screen.dart` | UI + social placeholders; no API |

### Tab shell (`TarzHomeScreen`)
| Index | Icon | Screen | Notes |
|-------|------|--------|-------|
| 0 | `catalog_icon.png` | `TarzCatalogueScreen` | Gender tabs, category list, uşaq banners |
| 1 | `hanger_icon.png` | `TarzOutfitsScreen` | **Kombinlərim** — empty placeholder |
| 2 | `home_icon.png` (center circle) | Home scroll | Default tab on launch |
| 3 | `favorite_border` | `TarzWishlistScreen` | 2-column grid or empty state |
| 4 | `person_outline` | `TarzProfileScreen` | Menu + login/register CTAs |

**Cart is NOT in bottom nav** — opened via header cart icon or catalogue search bar.

### Home screen sections (index 2)
| Section | Widget | Details |
|---------|--------|---------|
| Header | `HomeSearchHeader` | Search tap, notifications bell, cart badge |
| Gender tabs | `GenderSegmentedTabs` | Qadın / Kişi / Uşaq (local state only) |
| Hero banner | `HeroCollageBanner` | Single Figma image `slider_banner.png` |
| Yenilər | `NewProductsSection` | 2-column grid; 2 products with real images |
| AI outfit | `AiOutfitBanner` | CTA → toast placeholder |
| Kateqoriyalar | `CategoryGridSection` | 2×2 split cards: colored label + photo |
| Brendlər | `BrandBannerSection` | Horizontal scroll; `brands_yerli.png` full banner |
| Mağazalar | `StoreChipsSection` | 2-row horizontal scroll; white cards, black text |

### Catalogue
- Gender selector (Qadın / Kişi / Uşaq)
- **Qadın/Kişi:** animated underline category list → PLP
- **Uşaq:** 3 full-width Figma banners (Körpələr, Oğlanlar, Qızlar)
- Search bar + cart icon in header

### PLP — Product Listing Page
- File: `tarz_category_listing_screen.dart`
- 2-column product grid (`plp_product_card.dart`)
- Sticky filter bar: Kateqoriyalar, Filtr, Sırala
- Sort bottom sheet (client-side only)
- Category bottom sheet
- Shimmer loading state, empty state
- Wishlist heart sync
- Filter opens `/filter` but **does not apply results back**

### PDP — Product Details Page
- File: `product_details_screen.dart`
- Gallery with 2 product thumbnails (`TarzProductAssets.all`)
- Price, brand, size selector (XS–XL), reviews section (mock)
- Add to cart, wishlist toggle
- Related products horizontal scroll
- Demo title override: `Nike V5 RNR` displays as `Brown Check Asymmetric Wrap Skirt` (Figma demo)

### Cart
- File: `tarz_cart_screen.dart`
- Item tiles with qty controls
- Promo code expandable section (UI only)
- Gift wrap toggle (+10₼)
- Summary + sticky checkout button (no payment flow)

### Filter
- File: `tarz_filter_screen.dart`
- Full filter UI: seasons, price range, categories, colors, sizes, brands
- Apply button does not return filter state to PLP

### Search
- File: `tarz_search_screen.dart`
- Search field UI; submit shows toast — **no results**

### Notifications
- File: `tarz_notifications_screen.dart`
- Route: `/notifications`
- Empty state: «Hələ bildiriş yoxdur»
- Opened from home header bell or profile menu

### Profile menu items
| Item | Action |
|------|--------|
| Sifarişlərim | Toast placeholder |
| Seçilmişlər | Nav tab 3 |
| Kombinlərim | Nav tab 1 |
| Bildirişlər | `/notifications` |
| Dil — Azərbaycan | Toast placeholder |
| Kömək | Toast placeholder |

### Drawer
- `TarzHomeDrawer` — gender selection + category labels (toast only)

---

## Navigation Flow

### Startup (current — dev mode)
```
SplashScreen (3s)
  └─ pushReplacementNamed(/home)
       └─ HomeScreen → TarzHomeScreen(initialNavIndex: null → defaults to 2)
```

### Startup (intended production)
```
SplashScreen
  ├─ token valid → /home
  └─ no token → /login → /home
```

### Tab shell
```
_navIndex:
  0 → TarzCatalogueScreen
  1 → TarzOutfitsScreen
  2 → Home scroll (CustomScrollView)
  3 → TarzWishlistScreen
  4 → TarzProfileScreen
```

### Pushed routes from home/catalogue
```
HomeSearchHeader / CatalogueSearchBar
  ├─ /search
  ├─ /notifications
  └─ /cart

Category / See All taps
  └─ /listing/products  (ProductListingArgs: title + products)

Product card tap
  └─ /product/details   (ProductDetailsArgs: product + similarProducts)

PLP filter bar
  └─ /filter            (optional productCount int arg)

Profile
  ├─ /login
  └─ /register
```

### Route table

| Constant | Path | Screen | Arguments |
|----------|------|--------|-----------|
| `splash` | `/splash` | SplashScreen | — |
| `home` | `/home` | HomeScreen → TarzHomeScreen | `int?` nav index |
| `login` | `/login` | LoginScreen | — |
| `register` | `/register` | RegisterScreen | — |
| `search` | `/search` | TarzSearchScreen | — |
| `filter` | `/filter` | TarzFilterScreen | `int?` productCount |
| `productListing` | `/listing/products` | TarzCategoryListingScreen | `ProductListingArgs` |
| `productDetails` | `/product/details` | ProductDetailsScreen | `ProductDetailsArgs` |
| `cart` | `/cart` | TarzCartScreen | — |
| `notifications` | `/notifications` | TarzNotificationsScreen | — |
| *(default)* | *unknown* | HomeScreen | — |

---

## Packages and Dependencies

### Runtime (`dependencies`)
| Package | Version | Usage |
|---------|---------|-------|
| `flutter` | SDK | Framework |
| `cupertino_icons` | ^1.0.8 | iOS-style icons (minimal use) |

### Dev (`dev_dependencies`)
| Package | Version | Usage |
|---------|---------|-------|
| `flutter_test` | SDK | Testing (no tests written) |
| `flutter_lints` | ^5.0.0 | Lint rules |
| `flutter_launcher_icons` | ^0.14.3 | Generate Android/iOS app icons from `tesicon.png` |

### Not included (but likely needed for production)
- `http` or `dio` — API calls
- `flutter_secure_storage` or `shared_preferences` — token / persistence
- `cached_network_image` — remote product images
- State management package (optional if controllers grow)

---

## API / Backend Integration Status

**Status: Not started.**

| Area | Current source | Future target |
|------|----------------|---------------|
| Products / listings | `TarzMockCatalog` | `GET /products`, `GET /products/:id` |
| Home sections | Static mock methods | `GET /home/sections` or composed endpoints |
| Categories | `catalogueCategories` const list | `GET /categories?gender=` |
| Stores | `StoreChipsSection.mockStores()` | `GET /stores` |
| Cart | `TarzCartController` in-memory | `GET/POST/PATCH/DELETE /cart` |
| Wishlist | `TarzWishlistController` in-memory | `GET/POST/DELETE /wishlist` |
| Auth | UI only | `POST /auth/login`, `/register`, social OAuth |
| Search | Toast on submit | `GET /search?q=` |
| Notifications | Empty state | `GET /notifications` |
| Outfits (Kombinlərim) | Placeholder | `GET/POST /outfits` |
| Orders | Toast | `GET /orders` |

### Suggested service layer (not built)
```
lib/config/api_config.dart       # base URL, env flags
lib/services/api_client.dart     # HTTP wrapper
lib/services/auth_service.dart
lib/services/auth_storage.dart
lib/repositories/product_repository.dart
lib/repositories/cart_repository.dart
```

---

## Environment Configuration

| Item | Status |
|------|--------|
| `.env` files | **None** |
| Flavor / staging configs | **None** |
| API base URL constant | **None** |
| Feature flags | **None** |

All configuration is implicit: mock data hardcoded in Dart files.

---

## Assets

Registered in `pubspec.yaml`:

```
assets/splashscreen.png
assets/banners/winter.png
assets/banners/mehman.jpg
assets/banners/yakup.png
assets/banners/Tomy.png
assets/banners/ai_tile_square_2.png
assets/banners/slider_banner.png          # Home hero banner
assets/banners/brands_yerli.png           # Brendlər section (470×283)
assets/icon/tesicon.png
assets/nav/home_icon.png                  # ⚠ ~199 bytes — likely corrupt
assets/nav/catalog_icon.png
assets/nav/hanger_icon.png
assets/stores/                            # Sterns, Fabiani, Gant PNGs (legacy)
assets/catalogue/                         # children_korpeler/oglanlar/qizlar.png
assets/products/nike_v5_rnr.png           # Used for ALL product mocks (alternating)
assets/products/green_cardigan.png
```

### Asset constant classes
| Class | Path prefix |
|-------|-------------|
| `TarzBannerAssets` | `assets/banners/` |
| `TarzCatalogueAssets` | `assets/catalogue/` |
| `TarzNavAssets` | `assets/nav/` |
| `TarzStoreAssets` | `assets/stores/` |
| `TarzProductAssets` | `assets/products/` |

### Product image convention
All mock products alternate between `nike_v5_rnr.png` and `green_cardigan.png` via `TarzProductAssets.demoAt(index)`. Category grid and AI banner still use older banner assets for lifestyle photos.

---

## Mock Data Reference

### `TarzMockCatalog` key methods
| Method | Used by |
|--------|---------|
| `categories` | Home gender tabs |
| `catalogueCategories` | Catalogue list (Qadın/Kişi) |
| `childrenCatalogueBlocks()` | Catalogue uşaq mode |
| `homeNewProductsGrid()` | Home Yenilər (2 items) |
| `homeYeniler()` | Yenilər «See all» PLP |
| `homeEndirim()` | Legacy carousel (unused in current home) |
| `homeTrendler()` | Brendlər PLP mapping |
| `trendListingDemo()` | Default PLP demo (8 items) |
| `endirimListingDemo()` | Endirimlər PLP |
| `trending()`, `forYou()` | Defined but not wired to current UI |

### Store mock data (current)
White cards with black uppercase text:
`STERNS`, `FABIANI`, `ARCHIVE`, `BOTTEGA VENETA`, `GANT`, `THE FIX`

Card size: **186×111**, gap **12px**, 2-row horizontal scroll.

---

## Pending Tasks and Roadmap

### High priority
1. **Backend API integration** — products, categories, stores, cart, auth, wishlist, search
2. **Auth persistence** — secure token storage; splash token check
3. **Login / Register API** — spec discussed, not implemented
4. **Filter → PLP** — return `FilterResult` and apply to listing
5. **Search results** + debounced API query
6. **Checkout / payment** flow from cart sticky button
7. **Persist cart & wishlist** (local SQLite or API sync)
8. **Kombinlərim** — real screen + API (currently empty placeholder)
9. **`AppRoutes.aiOutfit`** — AI outfit creation flow

### Medium priority
10. Repository layer replacing direct `TarzMockCatalog` usage
11. Gender tab → reload home/catalogue content from API
12. Store card tap → store PLP or store detail page
13. Category grid tap → category PLP
14. Brand banner tap → brand PLP
15. Fix `README.md` merge conflict
16. Replace/fix `assets/nav/home_icon.png` (199 bytes — likely broken PNG)
17. Add proper Flutter `launch.json` for mobile (current config is Chrome stub)

### Low priority
18. Remove or archive unused legacy widgets
19. Add `cached_network_image` when using remote URLs
20. Widget / integration tests
21. CI/CD pipeline
22. i18n framework (currently hardcoded AZ strings)

---

## Known Bugs and Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| No API / persistence | **High** | All data lost on app restart |
| Auth bypassed at splash | **High** | Intentional for UI dev |
| Filter UI doesn't affect PLP | **Medium** | Filter screen is isolated |
| Search has no results | **Medium** | Toast only on submit |
| Kombinlərim placeholder only | **Medium** | Empty state message |
| Notifications always empty | **Low** | By design until API |
| `README.md` merge conflict | **Medium** | `<<<<<<< HEAD` markers present |
| `home_icon.png` corrupt/small | **Low** | 199 bytes; may show broken icon in nav |
| PDP demo title override | **Low** | Nike V5 RNR → Brown Check Skirt (Figma demo hack) |
| Legacy widgets clutter repo | **Low** | Unused files not deleted |
| `assets/stores/` PNGs unused | **Low** | Mağazalar now uses text labels |
| No test directory | **Low** | `flutter test` fails — no `test/` folder |

### Fixed issues (for context)
- **Brendlər negative padding crash** — `ListView` right padding was `horizontalPadding - peekWidth` (negative). Fixed to symmetric positive padding with width-based peek calculation.
- **Brendlər banner** — now uses full Figma export image instead of overlay text on wrong banner assets.

---

## Build and Run Instructions

### Prerequisites
- Flutter SDK compatible with `^3.8.1`
- Android Studio / Xcode for device builds
- `flutter doctor` should pass for target platform

### Setup
```bash
cd tessera
flutter pub get
flutter analyze lib
```

### Run
```bash
flutter run                    # default connected device
flutter run -d chrome          # web (if enabled)
flutter run -d <device_id>     # specific device
```

### Regenerate app icons (after changing `assets/icon/tesicon.png`)
```bash
dart run flutter_launcher_icons
```

### Entry point
- `lib/main.dart`
- `initialRoute: AppRoutes.splash`
- Splash waits 3 seconds then navigates to `/home`

### VS Code / Cursor launch
`.vscode/launch.json` currently contains a **Chrome localhost stub**, not a Flutter mobile launch config. Use terminal `flutter run` or add a proper Flutter launch configuration.

---

## Important Implementation Details

### 1. Hanger icon = Kombinlərim (not cart)
Early prototype mapped hanger to cart. **Current behavior:** index 1 opens `TarzOutfitsScreen`. Cart is only via pushed route `/cart`.

### 2. Home is default tab
`TarzHomeScreen` initializes `_navIndex = widget.initialNavIndex ?? 2` — center home tab on launch.

### 3. Login screen has bottom navigation
`LoginScreen` includes `TarzBottomNavigation` — tapping tabs navigates to `/home` with that tab index (except profile tab 4).

### 4. Product images — single pair reused
Only 2 product PNGs exist. All mocks reference them via `TarzProductAssets.nikeV5Rnr` / `greenCardigan` or `demoAt(i)`.

### 5. Children catalogue banners
`TarzChildrenCatalogueBlock.fullWidthBanner = true` renders the entire Figma export as one image (text baked into PNG). No separate text overlay.

### 6. Category grid layout
Each card is 50/50 split: left colored panel with white label, right `Image.asset` with `BoxFit.cover`.

### 7. Brand banner layout
- Card aspect from Figma: 470×283 (`TarzHomeLayout.brandFrameWidth/Height`)
- Horizontal `ListView` with 32px peek of next card
- Same `brands_yerli.png` duplicated for scroll demo (2 items)

### 8. Store cards layout
- White background `#FFFFFF`, border `#D9D9D9`, label `#111111`
- 2 columns × N rows in horizontal scroll
- `TarzStorePreview` has optional `logoAsset` — if null, shows text label

### 9. Price parsing
`TarzPriceUtils.parseManat()` extracts numeric value from strings like `150₼`, `89 AZN`. Used in cart summary and PLP sort.

### 10. Cart item ID
Composite key: `{productId}_{size}` — same product different sizes = separate line items.

### 11. Wishlist seeding
First call to `ensureLoaded()` / `add()` / `toggle()` seeds 4 items from `homeNewProductsGrid()`.

### 12. Content max width
`TarzBreakpoints.contentMaxWidth()` constrains scroll content on wide screens/tablets.

---

## Assumptions and Conventions

| Convention | Detail |
|------------|--------|
| **Language** | All user-facing strings in **Azerbaijani** |
| **Currency** | Display as `₼`; parsing accepts `AZN` suffix too |
| **Design reference** | Figma exports copied to `assets/`; layout constants in `TarzHomeLayout` |
| **Module naming** | Commerce code under `tarz/` prefix (Tarz = project UI codename) |
| **No DI** | Singleton controllers accessed directly |
| **Toast pattern** | `ScaffoldMessenger.showSnackBar` for unimplemented actions |
| **TODO comments** | Mark API integration points — search codebase for `TODO:` |
| **Mock replacement** | Replace `TarzMockCatalog` methods with repository calls; keep model classes |
| **Route args** | Always use typed args classes, not raw Maps |
| **Asset naming** | snake_case filenames; constants in `*Assets` abstract classes |
| **Do not redesign** | Treat existing UI as source of truth unless explicitly asked |
| **Git** | Do not commit unless user asks; `README.md` needs conflict resolution |

---

## Key Files Cheat Sheet

| Task | File |
|------|------|
| App entry + global rebuild | `lib/main.dart` |
| All routes | `lib/routes/app_routes.dart` |
| Tab shell + home composition | `lib/tarz/tarz_home_screen.dart` |
| Bottom navigation | `lib/tarz/widgets/tarz_bottom_navigation.dart` |
| Mock product data | `lib/tarz/data/tarz_mock_catalog.dart` |
| Cart logic | `lib/tarz/cart/tarz_cart_controller.dart` |
| Wishlist logic | `lib/tarz/wishlist/tarz_wishlist_controller.dart` |
| PLP | `lib/tarz/screens/tarz_category_listing_screen.dart` |
| PDP | `lib/tarz/screens/product_details_screen.dart` |
| Cart UI | `lib/tarz/screens/tarz_cart_screen.dart` |
| Filter UI | `lib/tarz/screens/tarz_filter_screen.dart` |
| Catalogue | `lib/tarz/screens/tarz_catalogue_screen.dart` |
| Kombinlərim | `lib/tarz/screens/tarz_outfits_screen.dart` |
| Notifications | `lib/tarz/screens/tarz_notifications_screen.dart` |
| Profile | `lib/tarz/screens/tarz_profile_screen.dart` |
| Home Yenilər | `lib/tarz/widgets/home/new_products_section.dart` |
| Home Kateqoriyalar | `lib/tarz/widgets/home/category_grid_section.dart` |
| Home Brendlər | `lib/tarz/widgets/home/brand_banner_section.dart` |
| Home Mağazalar | `lib/tarz/widgets/home/store_chips_section.dart` |
| Home hero | `lib/tarz/widgets/home/hero_collage_banner.dart` |
| Figma layout constants | `lib/tarz/theme/tarz_home_layout.dart` |
| Asset paths | `lib/tarz/data/tarz_*_assets.dart` |

---

## Handoff Checklist for New Developer

1. Read this file + skim `tarz_home_screen.dart` and `app_routes.dart`
2. Run `flutter pub get && flutter analyze lib && flutter run`
3. Verify home tab loads all sections (hero, Yenilər, Kateqoriyalar, Brendlər, Mağazalar)
4. Test flow: product card → PDP → add to cart → cart screen
5. Note splash skips login — expected for now
6. Before API work: agree on endpoint spec, add `http`/`dio`, create `lib/services/`
7. Update this document after any navigation, route, or architecture change

---

*Maintained manually. Update after major features, Figma section changes, or API integration milestones.*
