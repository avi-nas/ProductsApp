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

## AI mistakes and corrections

- A synthesized optional decoder would have accepted a missing `rating` key. The DTO was changed to require the key while accepting explicit `null`.
- Xcode’s generated Info.plist omitted the custom `API_BASE_URL` during the first test launch. Explicit Dev and secure plist templates fixed startup configuration.
- An initial empty-state draft used `ContentUnavailableView`, which requires iOS 17. It was replaced with native custom state views to preserve the iOS 16 target.
- The first networking implementation converted cancellation into a transport failure. Final review preserved `CancellationError`, preventing false connectivity errors in cancelled UI tasks.
- The enquiry ViewModel initially inspected networking-layer `APIError` details. Final review moved translation into the Data repository and exposed a Domain enquiry error instead.
- The initial Xcode project added physical subfolder paths as flat file references, causing names such as `App/DependencyContainer.swift` to appear in the navigator. The project references were rebuilt as nested groups matching the on-disk App, Core, Domain, Data, Features, Shared, Support, and test folders.
- Simulator screenshots verified the live Home screen in light and dark mode, but interactive Device Hub control lacked macOS Computer Use permission. Nested-screen visual traversal is explicitly unverified rather than fabricated.

## Verification performed with AI assistance

- Built the Dev scheme and ran the complete XCTest suite.
- Exercised all six backend endpoints against the running ProductsBackend.
- Confirmed exactly five featured products, category ranking, search results and empty search, and product details.
- Submitted a fresh enquiry and confirmed `submitted: true` plus a new Mailpit message containing customer and product information.
- Reviewed tracked/untracked files for secrets, build output, and user-specific Xcode state.

## Time record

A reliable stopwatch-style split across planning, building, testing, and review was not captured during the iterative chat sessions. No retrospective duration is provided because it would be fabricated. This is a submission limitation; future challenge work should start a time log before implementation.

No commits or pushes were performed by the AI.
