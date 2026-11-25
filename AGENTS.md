# ProductsApp agent guide

ProductsApp is a SwiftUI client for the implemented contract at `../ProductsBackend/API_CONTRACT.md`. Treat that file—not Fake Store or assumptions—as the networking source of truth. Preserve the scope and decisions in `PLAN.md` and `DECISIONS.md`.

## Boundaries and dependencies

- Presentation imports Domain, never Data DTOs or `URLSession`. Views render state and emit actions; view models perform async orchestration.
- Domain contains value models and repository protocols only. It must not import SwiftUI or know JSON/envelopes.
- Data contains HTTP code, DTOs, explicit DTO-to-domain mapping, and live repository implementations.
- Construct live dependencies once in `ProductsAppApp`/`DependencyContainer`; inject protocols through initializers. Do not use singletons, global mutable state, a service locator, or a DI framework.
- Add no third-party dependency unless a concrete requirement cannot be met by Swift/Foundation/SwiftUI/XCTest.
- Never call `fakestoreapi.com` from the app. Every product and enquiry request goes to the configured ProductsBackend base URL.

## Swift conventions

- Prefer small focused types, value semantics, `let`, explicit access control, and async/await. Avoid force unwraps, force casts, implicitly unwrapped optionals, and detached tasks.
- Mark UI-facing view models `@MainActor`. Model state explicitly (`idle`, `loading`, `loaded`, `empty`, `error`) rather than coordinating multiple booleans.
- Name protocols by capability (`CatalogueRepository`, `EnquiryRepository`, `HTTPClient`) and live implementations with a clear prefix (`LiveCatalogueRepository`).
- Domain models should conform only where used (`Identifiable`, `Hashable`, `Sendable`). DTOs conform to `Decodable`/`Encodable` and stay internal to Data.
- Use `URLComponents`/`URLQueryItem`; never concatenate unescaped category or search input into URLs.
- Cancel or ignore obsolete view-model tasks when a view disappears or a newer explicit request supersedes them. Prevent duplicate enquiry submissions.
- Build reusable views only after a real second use. Keep one-off feature UI inside its feature folder.

## API and error handling

- Decode all successful `/api/v1` responses through the required `data` envelope. Decode non-2xx responses through the backend error envelope, including optional `[String: [String]]` details.
- `ProductDTO.rating` is a required key with an optional value. Use custom decoding to reject a missing key while accepting explicit `null`; do not default null ratings to zero or make other required fields optional to hide contract errors.
- Map DTOs explicitly. Do not expose backend DTOs or `APIErrorDTO` to Domain/Presentation.
- Preserve featured-product and category-product order exactly as returned. Search is title/description matching performed by the backend; the client must not re-filter results.
- Treat `200` plus `submitted == true` as enquiry success. Surface validation details beside relevant fields where practical. Do not retry POST automatically.
- Distinguish invalid configuration/URL, transport, decoding, and server errors. User-facing messages must not expose raw response bodies, secrets, or internal diagnostics.
- Development uses the Dev XCConfig and local HTTP exception only. Do not commit secrets or enable unrestricted cleartext networking for stage/prod.

## UI expectations

- Use `NavigationStack` and typed `AppRoute` values. Do not navigate by embedding view models in route state.
- Every remote feature must show an appropriate loading state, meaningful error with Retry, and empty state when the successful payload is empty.
- Search performs no network request until explicit submit. Trim input and disable an empty submission.
- Product cards navigate consistently from Home, Category, and Search. Details handle image loading failure and nullable rating.
- Enquiry validates locally, remains editable after failure, disables submission while in flight, and reaches Thank You only after backend confirmation.
- Add accessibility labels/identifiers to product cards, retry controls, enquiry fields, submit, and success action when implementing each screen; do not postpone all accessibility work.

## Testing expectations

- Use XCTest only. Tests must not require ProductsBackend, Fake Store, Mailpit, wall-clock delays, or execution order.
- Mock repository protocols for view-model tests and `HTTPClient` for networking/data tests. Assert public state and requests, not private implementation details.
- Prioritize acceptance paths: Home featured/categories, Category section ordering, explicit Search and empty state, Details, Enquiry validation/success/failure, Thank You navigation, and retry behavior.
- Include contract boundaries: nullable rating, error envelope/details, URL encoding, non-2xx mapping, malformed JSON, and enquiry request encoding.
- Before handoff, build the Dev scheme and run the complete unit suite. Then perform one manual simulator smoke test against local ProductsBackend and verify the enquiry in Mailpit.

## Scope and handoff

- Do not add features outside the challenge or redesign backend contracts without recording the change in `DECISIONS.md` and updating integration documentation.
- Keep README setup executable from a clean checkout in under 10 minutes. Maintain `AI_USAGE.md` with actual interactions/corrections and an honest time log; never fabricate elapsed time.
- Do not commit or push unless explicitly requested. Preserve unrelated user changes and keep generated/user-specific Xcode files out of version control.
