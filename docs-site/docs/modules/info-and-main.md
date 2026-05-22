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
State is minimal and ephemeral. The current `InfoPage` is a static
`StatelessWidget`; there are no Info-specific providers in the current code.

### Widget Types & Patterns
- **Static Content Views**: Basic `Scaffold` implementations.
- **Navigation Target**: `/info` is one branch of the main shell.

---

## Main Module (`lib/features/main`)

The **Main Module** acts as the structural shell of the application post-authentication. It does not manage domain-specific features, but rather orchestrates how the user traverses them.

### State Management
State management is entirely delegated to `go_router`. The shell itself does not hold Riverpod state, but it reacts to route transitions to highlight the correct active tab.

### Widget Types & Patterns

The Main Shell utilizes `go_router`'s specialized navigation branch wrapper to maintain state across tabs.

```text
📦 MainShell
├── 📄 StatefulNavigationShell (go_router)
│   ├── 📑 Branch (Home)
│   ├── 📑 Branch (Medical)
│   ├── 📑 Branch (Notification)
│   ├── 📑 Branch (Info)
│   ├── 📑 Branch (Map)
│   └── 📑 Branch (Profile)
└── 🧭 NavigationBar
    ├── 🏠 Home Icon
    ├── 🏥 Medical Icon
    └── ...
```

:::warning[Nested Navigation]
The Main module implements a stateful nested navigation shell. This means that if a user navigates deep into a stack on the "Medical" tab, switches to "Home", and then switches back to "Medical", their deep stack state is perfectly preserved.
:::
