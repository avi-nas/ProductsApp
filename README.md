# ProductsApp

ProductsApp is a native SwiftUI catalogue for ProductsBackend. The selected challenge stack is **Swift/SwiftUI for iOS** plus the separate **Node.js/TypeScript ProductsBackend** repository. SwiftUI, `NavigationStack`, and async/await provide a compact native client with no third-party packages; the backend keeps Fake Store and SMTP concerns out of the app and makes both providers replaceable.

## Quick start (under 10 minutes)

Prerequisites:

- macOS with Xcode 16 or later and an installed iOS Simulator
- Node.js 20+ and Docker Desktop
- `ProductsApp` and `ProductsBackend` checked out as sibling directories

Expected layout:

```text
workspace/
  ProductsApp/
  ProductsBackend/
```

Start the backend and local Mailpit inbox:

```sh
cd ../ProductsBackend
test -f .env.dev || cp .env.example .env.dev
npm ci
docker compose up -d mailpit
npm run dev
```

Leave that terminal running. Verify the backend in another terminal:

```sh
curl --fail --silent --show-error http://127.0.0.1:3000/health
```

The response should be `{"status":"ok"}`. Then, from `ProductsApp`:

1. Open `ProductsApp.xcodeproj`.
2. Select the shared `ProductsApp-Dev` scheme and any iOS Simulator.
3. Run the app.

Home should load five featured products from the local backend. No paid service, external account, secret, or direct Fake Store client access is required.

## Verify the enquiry flow

Open a product, tap **Enquire about this product**, enter a name and email, and submit. The app shows Thank You only after backend-confirmed SMTP acceptance. Open [Mailpit](http://127.0.0.1:8025) and confirm the new sales email contains the customer and selected product details.

## Build and tests

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

Replace the simulator name with one listed by `xcrun simctl list devices available` if needed. Tests use repository and HTTP mocks and do not require the backend or Mailpit.

## Environments

| Scheme | Configuration | Backend URL | Transport |
| --- | --- | --- | --- |
| `ProductsApp-Dev` | `Dev.xcconfig` | `http://127.0.0.1:3000` | Development-only cleartext allowance |
| `ProductsApp-Stage` | `Stage.xcconfig` | Placeholder `.invalid` URL | HTTPS only |
| `ProductsApp-Prod` | `Prod.xcconfig` | Placeholder `.invalid` URL | HTTPS only |

Replace the stage and production placeholders with deployed ProductsBackend HTTPS URLs before using those schemes. `AppConfiguration` validates `API_BASE_URL` at startup. The XCConfig files contain no secrets.

## Architecture

```text
SwiftUI View -> @MainActor ViewModel -> Domain repository protocol
                                           |
                                  Data repository -> APIClient -> URLSession
```

- `App`: composition root and typed `NavigationStack` routing
- `Features`: feature-owned views and ViewModels
- `Domain`: UI-independent models, errors, and repository protocols
- `Data`: backend DTOs, explicit mapping, and live repositories
- `Core/Networking`: request construction, transport, decoding, and API errors
- `Shared/Views`: product presentation and common loading/empty/error states

All catalogue data and enquiries go through ProductsBackend. DTOs mirror `../ProductsBackend/API_CONTRACT.md`; all product fields are required, while the `rating` key is required and may contain `null`.

## Implemented flows

- Home: five backend-ordered featured products plus category navigation
- Category: backend-ranked top-rated and additional sections
- Search: explicit submission, results, empty state, error, and retry
- Product Details: image, description, USD price assumption, nullable rating, and enquiry action
- Enquiry: local validation, backend field errors, single in-flight submission
- Thank You: shown only after `submitted: true`, with navigation reset to Home

Remote screens provide loading, empty, retryable error, and pull-to-refresh behavior where appropriate. Known trade-offs and future priorities are documented in `DECISIONS.md`; AI assistance and corrections are documented in `AI_USAGE.md`.
