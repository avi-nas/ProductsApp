# ProductsApp

Native SwiftUI client for the ProductsBackend catalogue and enquiry API. Phase 1 provides the project foundation, environment configuration, networking, domain models, and repositories. Feature screens and view models are intentionally deferred.

## Requirements

- macOS with Xcode 16 or later
- iOS 16 or later simulator
- ProductsBackend at `/Users/avinashsharma/Documents/ProductsBackend`
- Node.js and Docker only when running the backend locally

No third-party iOS dependencies are used.

## Run locally

Start the backend in a separate terminal:

```sh
cd /Users/avinashsharma/Documents/ProductsBackend
cp .env.example .env.dev  # first setup only; keep this file uncommitted
npm ci
docker compose up -d mailpit
npm run dev
```

Confirm it is reachable:

```sh
curl --fail --silent --show-error http://127.0.0.1:3000/health
```

Then open `ProductsApp.xcodeproj`, select an iOS Simulator and the shared `ProductsApp-Dev` scheme, and Run. The Phase 1 root view is deliberately minimal.

Command-line verification:

```sh
xcodebuild build \
  -project ProductsApp.xcodeproj \
  -scheme ProductsApp-Dev \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO

xcodebuild test \
  -project ProductsApp.xcodeproj \
  -scheme ProductsApp-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Use any installed simulator name in the test command when `iPhone 17 Pro` is unavailable.

## Environments

| Scheme | Configuration | API URL source | Transport policy |
| --- | --- | --- | --- |
| `ProductsApp-Dev` | `Dev.xcconfig` | `http://127.0.0.1:3000` | Cleartext allowed for local development |
| `ProductsApp-Stage` | `Stage.xcconfig` | Staging placeholder | HTTPS only |
| `ProductsApp-Prod` | `Prod.xcconfig` | Production placeholder | HTTPS only |

Replace the `.invalid` stage and production URLs with deployed ProductsBackend URLs before using those schemes. `AppConfiguration` reads the generated `API_BASE_URL` Info.plist value and fails at startup when it is missing or is not an HTTP(S) URL. Environment files contain no secrets.

## Architecture

- `ProductsApp/App`: composition root, environment loading, navigation route definitions, minimal root view
- `ProductsApp/Core/Networking`: URLSession transport, request construction, decoding, and API errors
- `ProductsApp/Data`: backend DTOs, DTO-to-domain mapping, and live repository implementations
- `ProductsApp/Domain`: UI-independent models and repository protocols
- `ProductsApp/Features`: feature-owned presentation folders reserved for later phases
- `ProductsAppTests`: decoding, mapping, request/error handling, and repository tests

`DependencyContainer` is the only live composition point. Presentation code will depend on repository protocols; the concrete repositories route all catalogue and enquiry traffic exclusively through ProductsBackend.

## Backend coverage

`CatalogueRepository` covers:

- `GET /api/v1/home`
- `GET /api/v1/categories`
- `GET /api/v1/categories/:category/products`
- `GET /api/v1/products/search?q=`
- `GET /api/v1/products/:id`

`EnquiryRepository` covers:

- `POST /api/v1/enquiries`

The exact wire contract is maintained in `/Users/avinashsharma/Documents/ProductsBackend/API_CONTRACT.md`. DTOs keep backend names such as `imageUrl` and `productId`; domain models use Swift naming. Every product field is required, while the `rating` key is required and its value may be `null`.

## Current scope

The app currently renders only a build-verification root view. Home, category, search, details, enquiry, and thank-you presentation flows belong to subsequent phases. Stage/prod endpoints are deliberately unset placeholders because deployed backend URLs were not supplied.
