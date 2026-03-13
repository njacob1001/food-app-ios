# CLAUDE.md — food-app-ios

> Architecture and conventions guide for the Claude Code agent.
> Read this file **in full** before writing any line of code.
> If any instruction here conflicts with a one-off request, **ask before proceeding**.

---

## Project context

- **Platform:** iOS 17+, Swift 5.9+
- **UI framework:** SwiftUI (no UIKit unless strictly necessary)
- **Architecture:** Model-View (MV) with feature folders
- **Minimum deployment target:** iOS 17 — use `@Observable` freely, no `ObservableObject`
- **app folder**: `food-app-ios`
- **test folder**: `food-app-iosTests`
- **UI test folder**: `food-app-iosUITests`
- **Localization texts language**: All language texts in the app must be in spanish colombia


---

## Architecture — Model-View (MV)

This project uses **MV, not MVVM**. There are no ViewModels. Do not create ViewModel classes.

### The three roles

| Layer | What it is | Swift type |
|---|---|---|
| **Model** | Data + business logic | `struct` or `@Observable class` |
| **View** | Renders UI, reads model/service directly | `struct View` |
| **Service** | Side effects: API calls, persistence | `@Observable class` |

### Rules

- Views read from `@Observable` services and models directly — no intermediate ViewModel wrapper.
- `@State` is for local, ephemeral UI state only (sheet open/closed, text field focus, etc.).
- Never put network calls inside a View body or a `struct` model. They belong in a Service.
- A feature's Service is scoped to that feature. Only move it to `Core/` if two or more features need it.

### Example pattern

```swift
// Model — pure data
struct Recipe: Identifiable, Codable {
    let id: UUID
    var name: String
}

// Service — receives the API client via init
@Observable
final class RecipeService {
    var recipes: [Recipe] = []
    var error: (any Error)?

    private let apiClient: any APIProtocol

    init(apiClient: any APIProtocol) {
        self.apiClient = apiClient
    }

    func fetchRecipes() async {
        do {
            recipes = try await apiClient.listRecipes().ok.body.json
        } catch {
            self.error = error
        }
    }
}

// View — reads client from environment, passes it to the service
struct RecipeListView: View {
    @Environment(\.apiClient) private var apiClient
    @State private var service: RecipeService?

    var body: some View {
        List(service?.recipes ?? []) { recipe in
            Text(recipe.name)
        }
        .task {
            let svc = RecipeService(apiClient: apiClient)
            service = svc
            await svc.fetchRecipes()
        }
        .alert("Error", isPresented: .constant(service?.error != nil)) {}
    }
}
```

---

## Scaffolding

```
FoodApp/
├── App/
│   ├── FoodAppApp.swift        ← @main entry point
│   └── AppRouter.swift         ← NavigationStack + enum Route
│
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   ├── Models/             ← domain structs for this feature
│   │   └── Services/
│   ├── Recipe/
│   │   ├── Views/
│   │   ├── Models/
│   │   └── Services/
│   └── Profile/
│       ├── Views/
│       ├── Models/
│       └── Services/
│
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift     ← EnvironmentKey definition, do not modify
│   │   └── Generated/          ← auto-generated from openapi.json, never edit
│   ├── Storage/
│   │   └── PersistenceController.swift
│   └── DI/
│       └── ServiceContainer.swift
│
└── Shared/
    ├── Components/             ← stateless, business-agnostic UI components
    ├── Extensions/             ← View+Ext, Color+Ext, String+Ext
    └── Utils/                  ← DateFormatters, Validators
```

### `Features/`
Each feature owns its Views, Models, and Services. Features **must not import each other** — shared logic goes to `Core/` or `Shared/`.

### `Core/`
Infrastructure only: networking, persistence, DI. Nothing in `Core/` knows about a specific feature.

### `Shared/`
Reusable, **business-agnostic** SwiftUI components and utilities. No domain types allowed here.

### `App/`
Entry point only. No business logic.

---

## API client

`\.apiClient` is a custom `EnvironmentKey` defined in `Core/Network/APIClient.swift`. Its `defaultValue` points to the production server, so **any view can read it directly with no setup required**:

```swift
@Environment(\.apiClient) private var apiClient
```

No explicit `.environment()` injection is needed for production. Do not instantiate `APIClient` or `Client` directly anywhere in a feature — always read from the environment.

To override in Xcode Previews or unit tests, inject a mock locally:

```swift
#Preview {
    RecipeListView()
        .environment(\.apiClient, MockAPIClient())
}
```

### Rules

- Before writing any API call, read `openapi.json` to confirm the endpoint, method, and response shape.
- The API client is received by Services via `init(apiClient:)` — never called directly from a View body.
- Files in `Core/Network/Generated/` are auto-generated. Never edit them manually.

---

## Environment injection

`.environment()` propagates **downward** from the view where it is called to all its descendants — it is not global unless applied at the root.

Before writing `@Environment(\.someKey)` anywhere other than `\.apiClient`, verify that an ancestor in the same view hierarchy is explicitly injecting that key. If no ancestor injects it, SwiftUI silently uses the `defaultValue`, which can hide bugs.

`\.apiClient` is the exception — its `defaultValue` is production-ready, so no ancestor injection is needed.

---

## State management

| Use case | Tool |
|---|---|
| Local UI state (modal open, field focus) | `@State` |
| Service instance for a view subtree | `@State private var service = SomeService(...)` |
| Navigation path | `@State var path: [Route]` in the router view |
| Derived / computed values | Computed property on Model or Service |

- Use `@Observable` (iOS 17+). Do not use `ObservableObject`, `@Published`, `@StateObject`, or `@ObservedObject`.
- Do not use `@EnvironmentObject` — use `@Environment` with a typed key instead.

---

## Navigation

- Use `NavigationStack` with a typed `enum Route: Hashable`.
- Define app-level routes in `App/AppRouter.swift`.
- Views push routes — they do not instantiate destination views directly.
- `NavigationView` is deprecated — never use it.

```swift
enum AppRoute: Hashable {
    case recipeDetail(Recipe.ID)
    case profile
    case settings
}
```

---

## Naming conventions

| Thing | Convention | Example |
|---|---|---|
| Types | `UpperCamelCase` | `RecipeDetailView` |
| Properties and functions | `lowerCamelCase` | `fetchRecipes()` |
| Files | Match the primary type name | `RecipeDetailView.swift` |
| Boolean vars | `is`, `has`, `should` prefix | `isLoading`, `hasError` |
| Async functions | Imperative verb | `fetchRecipes()`, `deleteItem(id:)` |
| Feature Services | `<Feature>Service` | `RecipeService`, `CartService` |

---

## Platform conditionals

- Use `#if os(iOS)` / `#if os(macOS)` only for APIs that are genuinely platform-specific.
- Before writing a conditional, verify via MCP tools that the API is unavailable on the other platform.
- Do not wrap entire views in conditionals — create a separate file if the view differs per platform.

---

## Error handling

- Async functions that can fail should `throw`, or catch internally and store in `var error: (any Error)?` on the Service.
- Views bind `.alert` to the service's error property — they do not catch errors themselves.
- Use language from the glossary when displaying error messages to the user.

---

## Business terminology — Ubiquitous Language

All names in code (types, properties, functions, comments) must use the project's domain language.

1. Check if you have access to the `playbook` folder.
2. Open `docs/09-GLOSARIO.md` and read it fully. If you cannot access it, **stop and ask**.
3. If a domain concept is not in the glossary, **ask the user** before naming it, and prepare a change to add it.
4. Never invent names for business concepts — terms like "dish", "order", "venue", "booking" may have specific meanings here.

---

## Before writing code

1. Read this file top to bottom.
2. Check `docs/09-GLOSARIO.md` for domain terms involved in the task.
3. Read `openapi.json` to confirm endpoints, parameters, and response shapes.
4. Verify MCP tool arguments and API versions — do not assume from memory.
5. If the task touches more than one feature or is ambiguous, **ask before starting**.

---

## After writing code

- Verify no View is making API calls or containing business logic directly.
- Confirm every `@Environment(\.someKey)` (other than `\.apiClient`) has a matching `.environment()` call in an ancestor view.
- Check for accidental use of `ObservableObject`, `@Published`, `@StateObject`, or any `ViewModel` naming.
- Confirm new types follow the naming conventions above.
- If you introduced a new domain term, verify it is in the glossary or flag it.
- Remove all `TODO`, `FIXME`, and placeholder comments before finishing.

---

## Never do

- Create `ViewModel` classes — this is MV, not MVVM.
- Use `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject`.
- Instantiate `APIClient` or `Client` directly inside a feature — always use `@Environment(\.apiClient)`.
- Edit auto-generated files in `Core/Network/Generated/`.
- Let features import each other.
- Put business logic in `Shared/Components/`.
- Use `NavigationView` — it is deprecated.
- Hardcode user-facing strings — use `LocalizedStringKey` or a strings catalog.
