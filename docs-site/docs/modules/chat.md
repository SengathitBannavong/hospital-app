---
id: chat
title: Chat Module
sidebar_position: 10
---

# Chat Module

The **Chat Module** (`lib/features/chat`) adds a fifth bottom-navigation tab for
patient/staff conversations. It supports a room list, unread/activity badges,
per-room realtime messaging, image messages, and read receipts.

## State Management

| Provider | Description |
| :--- | :--- |
| `chatRoomsProvider` | Root-anchored room list, 60s lifecycle-aware poll, unread total, and activity markers. |
| `chatMessagesProvider(roomId)` | Per-room `autoDispose` state: latest page, older-page loading, WebSocket updates, pending sends, image sends, and mark-read. |
| `activeChatRoomProvider` | Current open room id; prevents counting activity for the room the user is reading. |
| `chatUnreadTotalProvider` | Derived unread count displayed in the Chat bottom-nav badge. |

## Screens

```text
📦 ChatRoomsPage (/chat)
├── 🧭 AppBar with unread badge
├── 🔄 RefreshIndicator
└── 📜 Room list → /chat/:room_id

📦 ChatMessagesPage (/chat/:room_id)
├── 🧭 AppBar with room name
├── 📜 Reversed message list + older-message pagination
├── 🆕 New-message pill when user is reading older messages
└── ✍️ Composer: text send + gallery image send
```

## Realtime Flow

Each message page opens `ws/chat?conversation_id=<id>&token=<jwt>` through
`ChatWebSocketService`. The socket is realtime-primary, but the notifier also
fetches the latest page on reconnect and runs a 25s backstop poll for silent
socket failures.

The room list has no socket. It polls `chat/get_rooms` every 60s while the app
is active, merges rooms in place, and flags activity when unread counts or last
message timestamps change.

## API Endpoints

| Endpoint | Purpose |
| :--- | :--- |
| `chat/get_rooms` | Room list and unread counts. |
| `chat/get_messages` | Paginated per-room history. |
| `chat/participants` | Name lookup for patient/staff senders. |
| `chat/send_message` | REST fallback contract; active sends currently go through WebSocket. |
| `chat/mark_read` | Marks the active conversation read. |
| `chat/close_room` | Repository support exists; no close-room UI yet. |
| `ws/chat` | Per-room realtime transport. |
| `util/upload` | Uploads image files before sending image messages. |

## Test Coverage

- `test/features/chat/data/chat_models_test.dart`
- `test/features/chat/data/chat_remote_data_source_test.dart`
- `test/features/chat/data/chat_websocket_service_test.dart`
- `test/features/chat/presentation/providers/chat_provider_test.dart`
