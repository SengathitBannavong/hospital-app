---
id: info-and-main
title: Info & Main Modules
sidebar_position: 7
---

# Info & Main Modules

These two modules are the structural glue and informational backbone of the application.

---

## Info Module (`lib/features/info`)

The **Info Module** contains all static content, regulatory information, and utility pages necessary for a public-facing healthcare application.

### State Management
State is minimal and ephemeral. Content is either entirely static or loaded via simple `FutureProvider` instances to fetch FAQ lists or Hospital Guidelines without complex mutability.

### Widget Types & Patterns
- **Static Content Views**: Basic `Scaffold` implementations heavily utilizing `SingleChildScrollView`.
- **Accordions/Expansion Panels**: Used extensively on the FAQ page to cleanly hide and show dense text.
- **Rich Text Rendering**: Uses packages or HTML rendering tools to display formatted privacy policies or terms of service correctly.

---

## Main Module (`lib/features/main`)

The **Main Module** acts as the structural shell of the application post-authentication. It does not manage domain-specific features, but rather orchestrates how the user traverses them.

### State Management
State management is entirely delegated to `go_router`. The shell itself does not hold Riverpod state, but it reacts to route transitions to highlight the correct active tab.

### Widget Types & Patterns

The Main Shell utilizes `go_router`'s specialized navigation branch wrapper to maintain state across tabs.

```text
📦 MainShell (ScaffoldWithBottomNavBar)
├── 📄 StatefulNavigationShell (go_router)
│   ├── 📑 Branch (Home)
│   ├── 📑 Branch (Map)
│   ├── 📑 Branch (Medical)
│   ├── 📑 Branch (Notification)
│   └── 📑 Branch (Profile)
└── 🧭 BottomNavigationBar
    ├── 🏠 Home Icon
    ├── 🗺️ Map Icon
    └── ...
```

:::warning[Nested Navigation]
The Main module implements a stateful nested navigation shell. This means that if a user navigates deep into a stack on the "Medical" tab, switches to "Home", and then switches back to "Medical", their deep stack state is perfectly preserved.
:::
