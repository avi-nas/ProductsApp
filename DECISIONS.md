# ProductsApp decisions

## Decisions and trade-offs

| Decision | Reason and trade-off |
| --- | --- |
| SwiftUI with iOS 16+ | `NavigationStack`, `AsyncImage`, and async/await cover the MVP with native APIs. Supporting older navigation APIs is outside the time-box. |
| Lightweight MVVM + Clean boundaries | Views stay declarative, view models own state, domain protocols isolate behavior, and Data owns HTTP/DTOs. View models call repositories directly; separate use-case objects would add ceremony without meaningful logic. |
| Feature-based Presentation, shared Domain/Data | Keeps each screen easy to find while avoiding duplicated product/network types across features. |
| Protocol injection at initializers | Enables mocks and replaceable repositories without a DI library. A single app-level container is the composition root, not a global service locator. |
| URLSession async/await | Native, sufficient, testable behind `HTTPClient`, and adds no package-management/setup cost. |
| DTO/domain separation | Backend JSON changes remain in Data; UI/domain code does not depend on envelopes, coding keys, or backend errors. Explicit mapping is small duplication with a clear boundary. |
| Backend ordering is authoritative | Featured order and category ranking are not recomputed on-device, preventing drift from server behavior. |
| One NavigationStack | Enough for all required flows. A coordinator framework, tab architecture, and deep-link system are unnecessary for the PoC. |
| XCTest with repository/HTTP mocks | Fast deterministic critical-path coverage. Snapshot tests and a broad UI-test suite would consume the remaining time without protecting core behavior proportionally. |
| Domain enquiry error | The Data repository translates backend validation details into domain field errors, so Presentation does not depend on `APIError` or backend envelopes. |
| Separate client/backend repositories | Keeps deployment and ownership independent. Reviewer setup assumes sibling checkouts so neither repository contains machine-specific paths. |
| System adaptation plus size-class refinement | Building with the current SDK gives navigation, bars, safe areas, resizing, and Split View native Duo behavior. A small shared Presentation container selects compact or regular content without device or pose detection; accessibility Dynamic Type deliberately uses the compact variant. |
| Even regular-width product grids | Home, Category, and Search distribute products across two columns so the inner display is useful and a folding division can separate columns cleanly. Compact-width structures remain unchanged. |
| Centralized `ArrangementView` availability | Product Details uses Apple’s horizontal split only when regular width can show both panes. The arrangement receives bounded space and each pane scrolls independently. The shared wrapper owns the only iOS 27.1 check; compact width, accessibility Dynamic Type, and older systems keep the complete vertical layout. |
| Native form for Enquiry | `Form` already supplies readable system margins, safe-area handling, keyboard behavior, and reserved-region adaptation. Custom width or fold calculations would reduce rather than improve platform consistency. |
| Preserve one navigation hierarchy across resizing | Keeping the existing `NavigationStack` and `@StateObject` ownership avoids rebuilding feature state when moving between inner/outer displays. A separate Duo coordinator or device-pose model is unnecessary. |
| Enable landscape explicitly | Both iPhone landscape orientations support tent and tabletop use while portrait behavior remains unchanged. Layout still responds to available geometry rather than reading interface orientation. |

## Assumptions

- The iOS Simulator uses `http://127.0.0.1:3000`; local-network cleartext permission is development-only. Stage and production URLs use HTTPS.
- Home combines two backend requests (`/home` and `/categories`). Either failure shows a page-level retry rather than partially loading the screen.
- Prices are displayed as USD because the backend provides no currency and Fake Store data is treated as USD. Currency remains a presentation assumption, not part of the domain/API contract.
- Category strings are displayed as returned (optionally capitalized for labels); the app does not correct upstream spelling such as `jewelery`.
- Search is explicit, not live/debounced. The client trims input, but backend matching and result order are authoritative.
- `rating` is always present in JSON but may be `null`; UI displays “Not rated” rather than inventing a zero rating.
- Enquiry contact details are name and email; message is optional. The client mirrors basic validation for UX, but backend field errors are the authority.
- A `200` enquiry with `submitted: true` is required before showing Thank You. No optimistic success or automatic POST retry.
- The Dev build permits cleartext transport for local loopback development. Stage and Prod use the secure plist and HTTPS-only URLs.
- iPhone Duo is treated as a resizable iPhone, not as a device-model branch. The system, not application code, interprets display and pose changes.

## Simplifications and limitations

- No local database, offline catalogue, image-cache layer, request retries, pagination, authentication, favourites/cart, analytics, localization, accessibility audit, or custom design system.
- `AsyncImage` uses system caching behavior; transient image failure shows a placeholder and does not fail the whole screen.
- App state is in memory. Navigation restoration and deep links are deferred.
- Error copy favors the backend safe message plus a retry action; detailed error localization is deferred.
- Stage and production backend URLs are placeholders because deployed environments were not supplied.
- Automated tests cover presentation state and repository interactions, but there is no UI/snapshot test target. Final visual inspection covered the live Home screen in light and dark mode plus selected Duo layouts; exhaustive nested-screen traversal is not claimed.
- Xcode 27.2 and iPhone Duo 27.1 simulators are installed. Device Hub inspection covered Product Details on the closed outer display and Home on the fully open inner display. The partially open pose, rotation, Split View, all-screen visual coverage, and end-to-end state-preservation matrix still require manual review.

## With another day

In priority order: manually complete the iPhone Duo pose/Split View/accessibility matrix; add one UI test for Home -> Details -> Enquiry -> Thank You; introduce image caching and lightweight catalogue caching; add structured client logging and request IDs; improve offline/retry behavior for idempotent GETs; then add localization and deep-link/navigation restoration.
