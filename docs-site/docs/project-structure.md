---
id: project-structure
title: Project Structure
sidebar_position: 3
---

# Project Structure

The codebase is organized to support a robust Flutter application utilizing a feature-first methodology. 

## Directory Tree

```
lib/
├── core/                        # Shared, domain-agnostic code
│   ├── config/                  # App configurations, environment variables
│   ├── constants/               # Global constants (API keys, strings)
│   ├── errors/                  # Custom exception classes and handlers
│   ├── navigation/              # AppRouter configuration (go_router)
│   ├── network/                 # Dio client, interceptors
│   ├── theme/                   # Colors, typography, shared visual styles
│   ├── utils/                   # Helpers, formatters
│   └── widgets/                 # Reusable UI components (buttons, text fields)
├── features/                    # Feature modules
│   ├── auth/                    # Login, signup, OTP, reset password
│   ├── chat/                    # Chat rooms, messages, WebSocket sync
│   ├── home/                    # Mobile dashboard
│   ├── info/                    # Static pages (FAQ, Hospital Guide)
│   ├── main/                    # Main shell (Bottom navigation wrapper)
│   ├── map/                     # 2D Map, routing, POI search
│   ├── medical/                 # Appointments, medical tasks, prescriptions
│   ├── notification/            # In-app notifications + push (FCM, optional)
│   ├── profile/                 # Profile view/edit
│   └── settings/                # Unified settings (theme, notifications, language)
└── main.dart                    # Application entry point
```

## Anatomy of a Feature

Inside each feature (e.g., `lib/features/auth/`), we adhere to clean architecture layers at a micro-level:

```
auth/
├── data/                        # Data layer: Repositories, models, DTOs
│   ├── auth_repository.dart
│   └── models/
├── domain/                      # (Optional) Core business entities if complex
└── presentation/                # UI Layer: Pages, Providers, Widgets
    ├── pages/
    ├── providers/
    └── widgets/
```
