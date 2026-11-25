# ProductsApp plan

## Goal and challenge coverage

Build a native SwiftUI catalogue that talks only to ProductsBackend. The critical paths are:

| Challenge requirement | Implementation task |
| --- | --- |
| Five featured products on Home | Load `GET /api/v1/home`; render the five products in backend-configured order. |
| Category navigation | Also load `GET /api/v1/categories` on Home and push the selected category. |
| Top-rated plus additional category products | Load `GET /api/v1/categories/:category/products`; render separate `topRated` and `additional` sections without client-side re-ranking. |
| Explicit search | Search only when the user submits or taps Search; call `GET /api/v1/products/search?q=` and show results or an empty state. |
| Product details | Push from any product card and load `GET /api/v1/products/:id`. |
| Product enquiry | Submit `POST /api/v1/enquiries`; show validation/server errors and navigate to Thank You only after `200`. |
| Resilient UX | Every loading screen has loading, loaded/empty, error, and retry behavior appropriate to that feature. |

Out of scope: authentication, favourites/cart, persistence, offline mode, custom image caching, analytics, pagination, localization, and elaborate visual design.

## Architecture

Use lightweight Clean Architecture with feature-based presentation:

```text
SwiftUI View → @MainActor ViewModel → Domain repository protocol
                                      ↓
                              Data repository → API client → URLSession → ProductsBackend
```

- **Presentation:** feature views, view models, navigation, UI state. No DTOs or `URLSession`.
- **Domain:** `Product`, `Rating`, `CategoryProducts`, and repository protocols. No SwiftUI or networking types.
- **Data:** exact backend DTOs, mapping, endpoints, API/error decoding, and repository implementations.
- **Composition:** one `DependencyContainer` created by the app and passed explicitly. No service locator, DI framework, or use-case classes for one-line repository calls.

## Proposed structure

```text
Configuration/
  Dev.xcconfig
  Stage.xcconfig
  Prod.xcconfig
ProductsApp/
  App/
    ProductsAppApp.swift
    AppRoute.swift
    DependencyContainer.swift
    AppConfiguration.swift
  Core/Networking/
    HTTPClient.swift
    URLSessionHTTPClient.swift
    APIClient.swift
    APIError.swift
  Domain/
    Models/Product.swift
    Models/CategoryProducts.swift
    Repositories/CatalogueRepository.swift
    Repositories/EnquiryRepository.swift
  Data/
    DTOs/APIEnvelopeDTO.swift
    DTOs/ProductDTO.swift
    DTOs/CategoryProductsDTO.swift
    DTOs/EnquiryDTO.swift
    Repositories/LiveCatalogueRepository.swift
    Repositories/LiveEnquiryRepository.swift
  Features/
    Home/{HomeView,HomeViewModel}.swift
    Category/{CategoryView,CategoryViewModel}.swift
    Search/{SearchView,SearchViewModel}.swift
    ProductDetails/{ProductDetailsView,ProductDetailsViewModel}.swift
    Enquiry/{EnquiryView,EnquiryViewModel,ThankYouView}.swift
  Shared/Views/
    ProductCard.swift
    LoadingView.swift
    ErrorView.swift
    EmptyView.swift
ProductsAppTests/
  Mocks/
  Networking/
  Repositories/
  ViewModels/
```

## Navigation flow

Use one `NavigationStack` and a small `AppRoute: Hashable`:

```text
Home ── category ──> Category ── product ──> Product Details ── enquire ──> Enquiry ── success ──> Thank You
  ├── product ─────────────────────────────> Product Details
  └── search button ──> Search ── product ─> Product Details
```

Routes carry stable values (`category` or product ID), not view models. Thank You provides a button that resets the navigation path to Home.

## Backend integration

Development base URL: `http://127.0.0.1:3000`. It is supplied through `API_BASE_URL` in XCConfig and exposed through an Info.plist build setting. Stage and production use their own HTTPS URLs. Allow local cleartext networking only in the development configuration; never embed the Fake Store URL in the app.

Use `URLComponents` for category path encoding and the `q` query item. All `/api/v1` successes decode through:

```swift
struct APIEnvelopeDTO<Value: Decodable>: Decodable { let data: Value }
```

Networking DTOs mirror the implemented contract exactly:

```swift
struct RatingDTO: Decodable { let rate: Double; let count: Int }
struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let imageUrl: URL
    let rating: RatingDTO?        // key is required; value may be null
}
struct HomeDTO: Decodable { let featuredProducts: [ProductDTO] }
struct CategoryProductsDTO: Decodable {
    let category: String
    let topRated: [ProductDTO]
    let additional: [ProductDTO]
}
struct EnquiryRequestDTO: Encodable {
    let name: String
    let email: String
    let productId: Int
    let message: String?
}
struct EnquiryResponseDTO: Decodable { let submitted: Bool }
struct APIErrorEnvelopeDTO: Decodable { let error: APIErrorDTO }
struct APIErrorDTO: Decodable {
    let code: String
    let message: String
    let details: [String: [String]]?
}
```

`ProductDTO` uses a small custom `init(from:)`: first require `container.contains(.rating)`, then decode the value with `decodeIfPresent`. This preserves the backend distinction between a required key containing `null` and a malformed response where `rating` is absent.

Endpoint mapping:

| Repository operation | Backend request | Decoded payload |
| --- | --- | --- |
| `home()` | `GET /api/v1/home` | `APIEnvelopeDTO<HomeDTO>` |
| `categories()` | `GET /api/v1/categories` | `APIEnvelopeDTO<[String]>` |
| `category(_:)` | `GET /api/v1/categories/:category/products` | `APIEnvelopeDTO<CategoryProductsDTO>` |
| `search(_:)` | `GET /api/v1/products/search?q=` | `APIEnvelopeDTO<[ProductDTO]>` |
| `product(id:)` | `GET /api/v1/products/:id` | `APIEnvelopeDTO<ProductDTO>` |
| `submitEnquiry(_:)` | `POST /api/v1/enquiries` | `APIEnvelopeDTO<EnquiryResponseDTO>` |

Map DTOs explicitly to domain models. Decode non-2xx bodies as `APIErrorEnvelopeDTO`; preserve status, backend code, message, and optional field details in `APIError.server`. Distinguish invalid URL, transport, decoding, and server errors. Do not retry POST automatically.

## Feature behavior and state

- **Home:** fetch Home and Categories concurrently; show one page-level loading/error state and Retry. An empty category array omits the category section.
- **Category:** backend order is authoritative. Omit an empty `additional` section; an unknown category shows the backend error with Retry/Back.
- **Search:** starts idle. Trim locally, disable submission for an empty query, and issue no request until explicit submit. A successful empty array shows “No products found.”
- **Details:** load by ID so deep navigation is stable. Show image placeholder/failure, nullable rating fallback (“Not rated”), description, price, and Enquire.
- **Enquiry:** required name/email, positive product ID from navigation, optional message. Mirror simple length/email checks for immediate feedback; backend validation remains authoritative. Disable duplicate submission while loading.
- **Thank You:** appear only after `submitted == true`; provide a return-to-home action.

## Implementation phases and time budget

Target 60–75 minutes for the remaining iOS work:

1. **Project/config/networking (15 min):** Xcode target, three XCConfigs, app configuration, HTTP/API clients, DTOs and errors.
2. **Domain/data (10 min):** models, mappings, repository protocols and live implementations.
3. **Features/navigation (30 min):** shared product UI plus Home, Category, Search, Details, Enquiry, Thank You and state handling.
4. **Tests/integration/handoff (15–20 min):** focused XCTest paths, simulator/backend smoke test, README, AI usage and actual time log.

If time tightens, preserve all acceptance paths and error/retry states; cut animations, previews, UI tests, and visual polish before architecture or critical unit tests.

## Focused testing strategy

- **Networking/data:** exact DTO mapping including accepted `rating: null` and rejected missing `rating` key; URL/path/query encoding; success envelope; backend error envelope; transport and decoding errors; enquiry POST encoding.
- **Home ViewModel:** concurrent success produces five featured products plus categories; one dependency failure produces retryable error.
- **Category ViewModel:** preserves backend `topRated`/`additional` order and handles missing/empty sections.
- **Search ViewModel:** no request before submit; trims query; success, empty, error and retry paths.
- **Details ViewModel:** success, nullable rating, not-found/error and retry.
- **Enquiry ViewModel:** local validation; success triggers Thank You; server field errors are displayed; failure never reports success; duplicate submit is blocked.
- Use XCTest with mock repository/HTTP-client protocols. Automated tests do not require ProductsBackend or the network. Perform one manual Dev-scheme smoke test against the local backend and Mailpit.

## Reviewer and submission checklist

- README states Swift/iOS choice, prerequisites, backend startup, XCConfig setup, scheme selection, simulator run, and tests; a reviewer should be running within 10 minutes.
- Commit no secrets. Commit safe XCConfig values/examples; stage/prod URLs are configurable.
- `AI_USAGE.md` records tools/models, 3–5 actual influential prompts/moments, errors caught, and corrections—without invented details.
- Record actual time spent across planning, building, testing and review immediately before submission.
- Build on a feature branch and leave a reviewed PR open into `main`; include setup, screenshots/behavior, test evidence, assumptions, cuts and known limitations in the PR description.
