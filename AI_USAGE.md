# AI usage

AI assistance was used throughout this AI-Native Engineer challenge. Every generated change was reviewed against the challenge, `PLAN.md`, `DECISIONS.md`, `AGENTS.md`, and the implemented backend contract.

## Tools and model

- OpenAI Codex desktop with its GPT-5-based coding agent
- Codex terminal execution and patch-based file editing
- Xcode, `xcodebuild`, XCTest, iOS Simulator, and `simctl`
- `curl`, Docker Compose, and Mailpit for local end-to-end verification
- Poppler rendering/text extraction for the final review of the supplied challenge PDF

No code-generation library, project generator, third-party iOS package, paid service, or external account was used.

## Agent instructions and plans

- `AGENTS.md` defined layer boundaries, Swift conventions, API/error rules, security expectations, and critical-path testing.
- `PLAN.md` mapped the challenge criteria to architecture, API contracts, navigation, phases, and tests.
- `DECISIONS.md` recorded assumptions, trade-offs, cuts, and future priorities.

## Representative prompts and influential moments

1. Plan the standalone ProductsBackend from the challenge, OpenAPI document, and real Fake Store responses, while keeping product and email providers replaceable.
2. Implement and verify the backend catalogue and enquiry phases, then create `API_CONTRACT.md` from the actual code as the iOS integration source of truth.
3. Plan ProductsApp with SwiftUI, lightweight MVVM/Clean boundaries, protocol injection, XCConfig environments, and no unnecessary dependencies.
4. Implement the iOS networking/domain foundation strictly from the backend contract, including the required-but-nullable `rating` key.
5. Implement and finally review all SwiftUI flows, state handling, navigation, validation, tests, local backend behavior, and Mailpit delivery without changing backend contracts.
6. Add iPhone Duo support from Apple’s official HIG and Tech Talks while preserving the iOS 16 target, existing architecture, and standard iPhone behavior.

## AI mistakes and corrections

- A synthesized optional decoder would have accepted a missing `rating` key. The DTO was changed to require the key while accepting explicit `null`.
- Xcode’s generated Info.plist omitted the custom `API_BASE_URL` during the first test launch. Explicit Dev and secure plist templates fixed startup configuration.
- An initial empty-state draft used `ContentUnavailableView`, which requires iOS 17. It was replaced with native custom state views to preserve the iOS 16 target.
- The first networking implementation converted cancellation into a transport failure. Final review preserved `CancellationError`, preventing false connectivity errors in cancelled UI tasks.
- The enquiry ViewModel initially inspected networking-layer `APIError` details. Final review moved translation into the Data repository and exposed a Domain enquiry error instead.
- The initial Xcode project added physical subfolder paths as flat file references, causing names such as `App/DependencyContainer.swift` to appear in the navigator. The project references were rebuilt as nested groups matching the on-disk App, Core, Domain, Data, Features, Shared, Support, and test folders.
- Simulator screenshots verified the live Home screen in light and dark mode. Device Hub later became accessible and was used to inspect the live app on the iPhone Duo 27.1 closed outer display and fully open inner display; broader nested-screen and pose traversal remains explicitly unverified rather than fabricated.
- The first Duo draft introduced a geometry policy and repeated availability/layout branches, then over-corrected by optimizing only Product Details. The final approach uses one shared size-class Presentation container for screens that benefit from regular-width composition and one shared wrapper containing the sole `ArrangementView` availability check.
- A live expanded-layout review exposed overlapping Product Details content because `ArrangementView` was nested inside an unbounded outer `ScrollView`. The correction moved the arrangement to the bounded content area, gave each pane independent scrolling, limited horizontal splitting to regular width, and removed a ratio constraint that hid the secondary pane. A subsequent Device Hub pass confirmed image-left and information-right rendering.
- The repository remote contained an embedded GitHub token. It was removed from the local remote URL before fetching; revocation in GitHub remains a required owner action.

## Verification performed with AI assistance

- Built the Dev scheme and ran the complete XCTest suite.
- Exercised all six backend endpoints against the running ProductsBackend.
- Confirmed exactly five featured products, category ranking, search results and empty search, and product details.
- Submitted a fresh enquiry and confirmed `submitted: true` plus a new Mailpit message containing customer and product information.
- Reviewed tracked/untracked files for secrets, build output, and user-specific Xcode state.
- Reviewed Apple’s iPhone Duo preparation guide, HIG, and supplied Tech Talks; checked the installed SwiftUI 27.1 API declarations for `ArrangementView` and `ReservedRegion`.
- Exported and applied Apple’s official `app-resizability` skill with `xcrun agent skills export`; its launch-screen, iPad-orientation, full-screen, main-screen, orientation, idiom, scene-lifecycle, and safe-area checks passed without source migrations.
- Scanned the app for `UIScreen.main`, device-orientation, interface-orientation, idiom, and status-bar layout assumptions; none were present.
- Built the availability-gated `ArrangementView` implementation with Xcode 27.2 while retaining an iOS 16 deployment target.
- Ran the complete suite on a standard iPhone 17 Pro simulator: 29 tests passed with no failures, skips, or test errors. A targeted build for the installed iPhone Duo 27.1 simulator also succeeded.
- Device Hub inspection confirmed Product Details on the closed outer display and the regular-width two-column Home layout on the fully open inner display. The app remained usable in both views. The partially open pose, rotation, Split View, every feature screen, and end-to-end state preservation were not completed and are not claimed.

## Time record

A reliable stopwatch-style split across planning, building, testing, and review was not captured during the iterative chat sessions. No retrospective duration is provided because it would be fabricated. This is a submission limitation; future challenge work should start a time log before implementation.

No commits or pushes were performed by the AI.
