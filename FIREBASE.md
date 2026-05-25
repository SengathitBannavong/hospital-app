# Firebase / Push Notifications

Firebase Cloud Messaging is **optional and OFF by default**. The app builds and
runs fully without any Firebase credentials; push registration and FCM listeners
are simply skipped.

## Why keys are not in the source

The real Firebase API keys were removed from version control:

- `lib/firebase_options.dart` reads each `apiKey` from a compile-time
  `String.fromEnvironment(...)` instead of a hardcoded literal.
- `android/app/google-services.json` ships with a **placeholder** key. The real
  file must be supplied at build time (locally or via CI) and must **not** be
  committed.

> ⚠️ Keys committed before this change are still in git history (commit
> `478bdbe`, already on `origin`). Rotate/restrict them in the Firebase / Google
> Cloud console — removing them from the working tree does not revoke them.

## Enabling Firebase

Pass the dart-defines and drop in the real `google-services.json`
(and `GoogleService-Info.plist` for iOS) before building:

```bash
flutter run \
  --dart-define=ENABLE_FIREBASE=true \
  --dart-define=FIREBASE_ANDROID_API_KEY=<android key> \
  --dart-define=FIREBASE_IOS_API_KEY=<ios key> \
  --dart-define=FIREBASE_WEB_API_KEY=<web key>
```

| dart-define | Purpose |
| --- | --- |
| `ENABLE_FIREBASE` | Master switch. Unset/`false` → Firebase fully disabled. |
| `FIREBASE_ANDROID_API_KEY` | Android `apiKey` for `firebase_options.dart`. |
| `FIREBASE_IOS_API_KEY` | iOS / macOS `apiKey`. |
| `FIREBASE_WEB_API_KEY` | Web / Windows `apiKey`. |

When `ENABLE_FIREBASE` is unset (the default), `main.dart` skips
`Firebase.initializeApp`, and `FirebaseNotificationService` / `AppInitializer`
short-circuit, so the in-app notification list still works over the normal
REST API.

> Note: the backend stores device tokens but does not send pushes yet, so even
> with Firebase enabled no push will arrive until the backend FCM sender ships.
