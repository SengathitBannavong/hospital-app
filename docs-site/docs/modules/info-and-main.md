---
id: info-and-main
title: Info & Main Modules
sidebar_position: 7
---

# Info & Main Modules

These two modules are the structural glue and informational backbone of the application.

---

## Info Module (`lib/features/info`)

The **Info Module** is the help hub for the public-facing app. `InfoPage`
(`/info`) is a **hub** that links three pushed sub-pages, each with its own
back button:

- **FAQ** (`/faq`) — expansion-panel question list with optional category chip filter, sourced from `util/faq`.
- **Giới thiệu / About** (`/about`) — hospital name, description, version, sourced from `util/about`.
- **Liên hệ / Contact** (`/contact`) — hotline, email, address from `util/contact`. Hotline taps open the dialer (`tel:`) and email taps open the mail app (`mailto:`) via `url_launcher`.

All are reached via `context.push(...)` (so the back arrow works), and the old
duplicate `/faq` route that shadowed the FAQ page was removed.

### State Management
The three sub-pages are now backend-driven. Each watches a Riverpod
`FutureProvider` from `lib/features/util/presentation/providers/util_providers.dart`
(`aboutProvider`, `contactProvider`, `faqProvider(category)`) and renders via
`AsyncValue.when(loading, error+retry, data)`. See the [Util Module](./util)
for repository details.

### Widget Types & Patterns
- **Hub list**: `InfoPage` is a `ListView` of `Card`/`ListTile` entries routing to each page.
- **Static Content Views**: Basic `Scaffold` + `SingleChildScrollView`.
- **Accordions/Expansion Panels**: Used on the FAQ page to hide/show dense text.

---

## Main Module (`lib/features/main`)

The **Main Module** acts as the structural shell of the application post-authentication. It does not manage domain-specific features, but rather orchestrates how the user traverses them.

### State Management
State management is entirely delegated to `go_router`. The shell itself does not hold Riverpod state, but it reacts to route transitions to highlight the correct active tab.

### Widget Types & Patterns

The Main Shell utilizes `go_router`'s specialized navigation branch wrapper to maintain state across tabs.

```text
📦 MainShell (ScaffoldWithBottomNavBar)
├── 📄 StatefulNavigationShell (go_router) — 4 branches
│   ├── 📑 Branch (Home)
│   ├── 📑 Branch (Medical)
│   ├── 📑 Branch (Map)
│   └── 📑 Branch (Profile)
└── 🧭 NavigationBar
    ├── 🏠 Trang chủ
    ├── 🏥 Y tế
    ├── 🗺️ Bản đồ
    └── 👤 Hồ sơ
```

:::note[Top-level pushed routes]
Notification, Info, FAQ, About, Contact, SOS, and Feedback are **not**
bottom-nav branches. They are top-level routes opened with `context.push(...)`,
so they appear as full pages with a back button rather than tabs.
:::

:::warning[Nested Navigation]
The Main module implements a stateful nested navigation shell. This means that if a user navigates deep into a stack on the "Medical" tab, switches to "Home", and then switches back to "Medical", their deep stack state is perfectly preserved.
:::
