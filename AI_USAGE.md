# AI usage

AI assistance has been used throughout this challenge as requested by the AI-Native Engineer exercise. This log records actual work and corrections; it does not estimate or invent elapsed time.

## Planning

- Reviewed the coding challenge, backend API contract, and the earlier ProductsBackend implementation context.
- Created and refined `PLAN.md`, `DECISIONS.md`, and `AGENTS.md` for a native SwiftUI client with lightweight MVVM/Clean Architecture.
- Kept feature presentation work outside Phase 1 and documented the separation between DTOs and domain models.

## Phase 1 implementation

- Created the SwiftUI application and XCTest targets, environment configurations, composition root, networking layer, domain models, and repositories for all six client endpoints.
- Derived the DTO shapes from `ProductsBackend/API_CONTRACT.md`, not from planning prose.
- Added focused tests for environment loading, product decoding and mapping, request construction, server/transport/decoding errors, and catalogue/enquiry repositories.
- Added reviewer setup and command-line verification instructions to `README.md`.

## Corrections made during implementation

- Enforced `rating` as a required JSON key whose value may be `null`. A synthesized optional decoder would also accept a missing key and would therefore be weaker than the backend contract.
- Percent-encoded each dynamic path segment so category names such as `men's clothing` are sent safely without changing their value.
- Added a development-only cleartext transport allowance for the documented `http://127.0.0.1:3000` backend. Stage and production configurations remain HTTPS-only.
- Created the Xcode project directly because no project generator was available; this avoided adding a build-time dependency that the plan did not require.
- Replaced generated Info.plist key injection with explicit development and secure plist templates after the first XCTest launch showed that Xcode omitted the custom `API_BASE_URL` key.

No feature screens, view models, third-party packages, commits, or pushes were produced in Phase 1.
