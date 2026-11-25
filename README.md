

https://github.com/user-attachments/assets/b6fa2400-77dc-4ac3-88ac-8ab2a2221310





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

## iPhone Duo and resizable layouts

Build with Xcode 27.1 or later to enable Apple’s full-display iPhone Duo behavior. The iOS 16 deployment target is unchanged.

- Standard `NavigationStack`, `Form`, `ScrollView`, toolbar, and safe-area behavior let iOS resize and reposition the existing interface across inner, outer, folded, and Split View configurations.
- Home retains its familiar horizontal compact presentation and expands categories and featured products into an even two-column regular-width grid.
- Category and Search retain product rows at compact width and distribute results across even two-column grids at regular width. Accessibility Dynamic Type uses the compact single-column presentation.
- Product Details uses a bounded, horizontal `ArrangementView` split at regular width on iOS 27.1 or later, keeping the image and product information in separate panes while responding to reserved folding regions. Compact widths, accessibility Dynamic Type, and iOS 16–27.0 use the complete vertical details layout.
- Enquiry remains a native `Form`, allowing the system to supply readable margins, keyboard avoidance, safe areas, and reserved-region behavior.
- Thank You places its confirmation and action vertically at compact width and side by side at regular width.
- The existing `NavigationStack`, `@StateObject` ViewModels, search query, enquiry fields, and navigation path remain alive while the window resizes between displays.
- System navigation and toolbar components retain Apple’s vertical placement. Foreground content remains inside system safe areas.
- Portrait and both landscape orientations are declared for iPhone; iPad also supports upside-down portrait.

There is no Duo-specific device detection, screen constant, pose model, interface-orientation branch, or custom reserved-region calculation. A shared size-class container owns compact/regular selection, and a shared split-arrangement wrapper owns the only iOS 27.1 availability check.

To inspect Duo layouts, choose an installed **iPhone Duo** simulator in Xcode Device Hub, then exercise closed, fully open, partially folded, rotated, and Split View configurations. Also regress the app on a standard iPhone simulator. See Apple’s [preparation guide](https://developer.apple.com/iphone-duo/prepare/) and [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo).
