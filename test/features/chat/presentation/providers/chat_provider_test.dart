import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/auth/data/auth_repository.dart';
import 'package:hospital_app/features/auth/data/models/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/core/services/chat_websocket_service.dart';
import 'package:hospital_app/features/chat/data/models/chat_message.dart';
import 'package:hospital_app/features/chat/data/models/chat_participants.dart';
import 'package:hospital_app/features/chat/data/models/chat_room.dart';
import 'package:hospital_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:hospital_app/features/chat/data/repository/chat_repository.dart';
import 'package:hospital_app/features/chat/presentation/pages/chat_messages_page.dart';
import 'package:hospital_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:hospital_app/features/util/data/models/upload_result.dart';
import 'package:hospital_app/features/util/data/repository/util_repository.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.testLoad(fileInput: 'BASE_URL=https://example.test/api/');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => null,
        );
  });

  group('ChatRoomsNotifier', () {
    test('flags changed rooms and skips the active room', () async {
      final fakeRepo = _FakeChatRepository(
        rooms: [
          _room(id: 1, unreadCount: 0),
          _room(id: 2, unreadCount: 0),
          _room(id: 3, unreadCount: 0),
        ],
      );
      final container = _container(fakeRepo: fakeRepo);
      addTearDown(container.dispose);

      final notifier = container.read(chatRoomsProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      container.read(activeChatRoomProvider.notifier).state = 2;

      fakeRepo.rooms = [
        _room(id: 1, unreadCount: 1),
        _room(id: 2, unreadCount: 1, lastMessageAt: '2026-05-30T10:05:00Z'),
        _room(id: 3, lastMessageAt: '2026-05-30T10:05:00Z'),
      ];
      await notifier.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(chatActivityRoomIdsProvider), {1, 3});
      expect(container.read(chatHasActivityProvider), isTrue);
      expect(container.read(chatUnreadTotalProvider), 2);
    });

    test('markRoomRead clears local chat activity dot', () async {
      final fakeRepo = _FakeChatRepository(
        rooms: [_room(id: 1, lastMessageAt: '2026-05-30T10:00:00Z')],
      );
      final container = _container(fakeRepo: fakeRepo);
      addTearDown(container.dispose);

      final notifier = container.read(chatRoomsProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      fakeRepo.rooms = [_room(id: 1, lastMessageAt: '2026-05-30T10:05:00Z')];
      await notifier.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(chatActivityRoomIdsProvider), {1});

      notifier.markRoomRead(1);

      expect(container.read(chatActivityRoomIdsProvider), isEmpty);
      expect(container.read(chatHasActivityProvider), isFalse);
    });

    test('polling timer cancels on dispose', () {
      final fakeRepo = _FakeChatRepository();
      final container = _container(fakeRepo: fakeRepo);

      final notifier = container.read(chatRoomsProvider.notifier);
      expect(notifier.debugIsPolling, isTrue);

      container.dispose();

      expect(notifier.debugIsPolling, isFalse);
    });
  });

  group('ChatMessagesNotifier', () {
    test(
      'markRead skips backend call when room has no unread messages',
      () async {
        final fakeRepo = _FakeChatRepository(rooms: [_room(id: 1)]);
        final container = _container(fakeRepo: fakeRepo);
        addTearDown(container.dispose);
        container.read(activeChatRoomProvider.notifier).state = 1;
        await container.read(chatRoomsProvider.notifier).load();

        await container.read(chatMessagesProvider(1).notifier).markRead();

        expect(fakeRepo.markReadCalls, 0);
      },
    );

    test(
      'markRead calls backend and clears unread incoming messages',
      () async {
        final fakeRepo = _FakeChatRepository(
          messages: [
            _message(id: 1, senderId: 7, senderType: 'staff', isRead: false),
          ],
          rooms: [_room(id: 1, unreadCount: 3)],
        );
        final container = _container(fakeRepo: fakeRepo);
        addTearDown(container.dispose);
        container.read(activeChatRoomProvider.notifier).state = 1;
        await container.read(chatRoomsProvider.notifier).load();
        await container.read(chatMessagesProvider(1).notifier).load();

        await container.read(chatMessagesProvider(1).notifier).markRead();

        expect(fakeRepo.markReadCalls, 1);
        expect(container.read(chatUnreadTotalProvider), 0);
        expect(
          container.read(chatMessagesProvider(1)).messages.single.isRead,
          isTrue,
        );
      },
    );

    test('markRead skips backend call when room is not active', () async {
      final fakeRepo = _FakeChatRepository(
        messages: [
          _message(id: 1, senderId: 7, senderType: 'staff', isRead: false),
        ],
        rooms: [_room(id: 1, unreadCount: 1)],
      );
      final container = _container(fakeRepo: fakeRepo);
      addTearDown(container.dispose);
      container.read(activeChatRoomProvider.notifier).state = null;
      await container.read(chatRoomsProvider.notifier).load();
      await container.read(chatMessagesProvider(1).notifier).load();

      await container.read(chatMessagesProvider(1).notifier).markRead();

      expect(fakeRepo.markReadCalls, 0);
      expect(container.read(chatUnreadTotalProvider), 1);
    });

    test(
      'sendMessage inserts optimistic message and reconciles echo',
      () async {
        final fakeRepo = _FakeChatRepository();
        final fakeWs = _FakeChatWebSocketService();
        final container = _container(fakeRepo: fakeRepo, fakeWs: fakeWs);
        addTearDown(container.dispose);

        final notifier = container.read(chatMessagesProvider(1).notifier);
        await notifier.load();

        await notifier.sendMessage('hello');

        var state = container.read(chatMessagesProvider(1));
        expect(state.messages, hasLength(1));
        expect(state.messages.single.id, isNegative);
        expect(state.messages.single.content, 'hello');
        expect(fakeWs.sentPayloads.single, {
          'type': 'text',
          'text_content': 'hello',
          'media_url': '',
        });

        notifier.handleWebSocketMessage({
          'message_id': 99,
          'conversation_id': 1,
          'sender_id': 42,
          'sender_type': 'user',
          'type': 'text',
          'text_content': 'hello',
          'created_at': '2026-05-30T10:00:00Z',
        });

        state = container.read(chatMessagesProvider(1));
        expect(state.messages, hasLength(1));
        expect(state.messages.single.id, 99);
        expect(fakeRepo.sendMessageCalls, 0);
      },
    );

    test(
      'echo with different sender id still reconciles optimistic message',
      () async {
        final fakeRepo = _FakeChatRepository();
        final fakeWs = _FakeChatWebSocketService();
        final container = _container(fakeRepo: fakeRepo, fakeWs: fakeWs);
        addTearDown(container.dispose);

        final notifier = container.read(chatMessagesProvider(1).notifier);
        await notifier.load();

        await notifier.sendMessage('hello');
        notifier.handleWebSocketMessage({
          'message_id': 101,
          'conversation_id': 1,
          'sender_id': 7,
          'sender_type': 'staff',
          'type': 'text',
          'text_content': 'hello',
          'created_at': '2026-05-30T10:00:00Z',
        });

        final state = container.read(chatMessagesProvider(1));
        expect(state.messages, hasLength(1));
        expect(state.messages.single.id, 101);
        expect(state.messages.single.id, isPositive);
      },
    );

    test('two identical text sends reconcile one-for-one', () async {
      final fakeRepo = _FakeChatRepository();
      final fakeWs = _FakeChatWebSocketService();
      final container = _container(fakeRepo: fakeRepo, fakeWs: fakeWs);
      addTearDown(container.dispose);

      final notifier = container.read(chatMessagesProvider(1).notifier);
      await notifier.load();

      await notifier.sendMessage('hi');
      await notifier.sendMessage('hi');

      var state = container.read(chatMessagesProvider(1));
      expect(state.messages, hasLength(2));
      expect(
        state.messages.map((message) => message.id),
        everyElement(isNegative),
      );

      notifier
        ..handleWebSocketMessage({
          'message_id': 201,
          'conversation_id': 1,
          'sender_id': 7,
          'sender_type': 'staff',
          'type': 'text',
          'text_content': 'hi',
          'created_at': '2026-05-30T10:00:01Z',
        })
        ..handleWebSocketMessage({
          'message_id': 202,
          'conversation_id': 1,
          'sender_id': 7,
          'sender_type': 'staff',
          'type': 'text',
          'text_content': 'hi',
          'created_at': '2026-05-30T10:00:02Z',
        });

      state = container.read(chatMessagesProvider(1));
      expect(state.messages, hasLength(2));
      expect(
        state.messages.map((message) => message.id),
        containsAll([201, 202]),
      );
      expect(
        state.messages.map((message) => message.id),
        everyElement(isPositive),
      );
    });

    test('load sorts messages newest-first by createdAt then id', () async {
      final fakeRepo = _FakeChatRepository(
        messages: [
          _message(id: 1, createdAt: '2026-05-30T10:00:00Z'),
          _message(id: 4, createdAt: '2026-05-30T10:02:00Z'),
          _message(id: 3, createdAt: '2026-05-30T10:02:00Z'),
          _message(id: 2, createdAt: '2026-05-30T10:01:00Z'),
        ],
      );
      final container = _container(fakeRepo: fakeRepo);
      addTearDown(container.dispose);

      await container.read(chatMessagesProvider(1).notifier).load();

      final ids = container
          .read(chatMessagesProvider(1))
          .messages
          .map((message) => message.id)
          .toList();
      expect(ids, [4, 3, 2, 1]);
    });

    test('load fetches latest backend page for large conversations', () async {
      final fakeRepo = _FakeChatRepository(
        messages: [
          for (var id = 1; id <= 60; id++)
            _message(id: id, createdAt: '2026-05-30T10:00:00Z'),
        ],
      );
      final container = _container(fakeRepo: fakeRepo);
      addTearDown(container.dispose);

      await container.read(chatMessagesProvider(1).notifier).load();

      final state = container.read(chatMessagesProvider(1));
      expect(fakeRepo.messagePageRequests, containsAllInOrder([1, 2]));
      expect(state.page, 2);
      expect(state.hasMore, isTrue);
      expect(
        state.messages.map((message) => message.id).toList(),
        List<int>.generate(10, (index) => 60 - index),
      );
    });

    test('loadMore fetches the previous older backend page', () async {
      final fakeRepo = _FakeChatRepository(
        messages: [
          for (var id = 1; id <= 60; id++)
            _message(id: id, createdAt: '2026-05-30T10:00:00Z'),
        ],
      );
      final container = _container(fakeRepo: fakeRepo);
      addTearDown(container.dispose);
      final notifier = container.read(chatMessagesProvider(1).notifier);
      await notifier.load();

      await notifier.loadMore();

      final state = container.read(chatMessagesProvider(1));
      expect(fakeRepo.messagePageRequests, containsAllInOrder([1, 2]));
      expect(fakeRepo.messagePageRequests.last, 1);
      expect(state.page, 1);
      expect(state.hasMore, isFalse);
      expect(state.messages, hasLength(60));
    });

    test(
      'sendImage uploads then sends over websocket optimistically',
      () async {
        final fakeRepo = _FakeChatRepository();
        final fakeWs = _FakeChatWebSocketService();
        final fakeUtil = _FakeUtilRepository();
        final container = _container(
          fakeRepo: fakeRepo,
          fakeWs: fakeWs,
          fakeUtil: fakeUtil,
        );
        addTearDown(container.dispose);
        final keepAlive = container.listen(chatMessagesProvider(1), (_, _) {});
        addTearDown(keepAlive.close);
        final image = File('${Directory.systemTemp.path}/chat-test-image.png');
        await image.writeAsBytes([1, 2, 3]);
        addTearDown(() async {
          if (await image.exists()) await image.delete();
        });

        final notifier = container.read(chatMessagesProvider(1).notifier);
        await notifier.load();

        await notifier.sendImage(image.path);

        final state = container.read(chatMessagesProvider(1));
        expect(fakeUtil.uploadCount, 1);
        expect(fakeWs.sentPayloads.single, {
          'type': 'image',
          'text_content': '',
          'media_url': '/uploads/test.png',
        });
        expect(state.messages, hasLength(1));
        expect(state.messages.single.id, isNegative);
        expect(state.messages.single.type, 'image');
        expect(state.messages.single.mediaUrl, '/uploads/test.png');
      },
    );

    test(
      'optimistic message persists without echo and load replaces it',
      () async {
        final fakeRepo = _FakeChatRepository();
        final container = _container(fakeRepo: fakeRepo);
        addTearDown(container.dispose);
        final notifier = container.read(chatMessagesProvider(1).notifier);
        await notifier.load();

        await notifier.sendMessage('no echo');

        var state = container.read(chatMessagesProvider(1));
        expect(state.messages.single.id, isNegative);

        fakeRepo.messages = [
          _message(
            id: 55,
            senderId: 42,
            senderType: 'user',
            content: 'no echo',
          ),
        ];
        await notifier.load();

        state = container.read(chatMessagesProvider(1));
        expect(state.messages, hasLength(1));
        expect(state.messages.single.id, 55);
      },
    );
  });

  group('isMineChatMessage', () {
    test('sender id match wins before role/type fallback', () {
      final message = _message(senderId: 9, senderType: 'staff');

      expect(isMineChatMessage(message, 9, 'patient'), isTrue);
    });

    test('patient role owns user messages only', () {
      expect(
        isMineChatMessage(_message(senderType: 'user'), 9, 'patient'),
        isTrue,
      );
      expect(
        isMineChatMessage(_message(senderType: 'staff'), 9, 'patient'),
        isFalse,
      );
    });

    test('staff role owns non-user messages only', () {
      expect(
        isMineChatMessage(_message(senderType: 'staff'), 9, 'staff'),
        isTrue,
      );
      expect(
        isMineChatMessage(_message(senderType: 'admin'), 9, 'staff'),
        isTrue,
      );
      expect(
        isMineChatMessage(_message(senderType: 'user'), 9, 'staff'),
        isFalse,
      );
    });
  });
}

class _FakeChatRepository extends ChatRepository {
  _FakeChatRepository({
    this.messages = const [],
    this.rooms = const [
      ChatRoom(
        id: 1,
        userId: 3,
        staffId: 7,
        status: 'open',
        name: 'Hỗ trợ',
        lastMessage: '',
        lastMessageAt: '',
        unreadCount: 0,
        avatarUrl: '',
      ),
    ],
  }) : super(
         remoteDataSource: ChatRemoteDataSource(
           dio: Dio(BaseOptions(baseUrl: 'https://example.test/api/')),
         ),
       );

  List<ChatMessage> messages;
  List<ChatRoom> rooms;
  final List<int> messagePageRequests = [];
  int sendMessageCalls = 0;
  int markReadCalls = 0;

  @override
  Future<List<ChatRoom>> getRooms({int page = 1, int limit = 50}) async {
    return rooms;
  }

  @override
  Future<List<ChatMessage>> getMessages({
    required int conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    return (await getMessagesPage(
      conversationId: conversationId,
      page: page,
      limit: limit,
    )).messages;
  }

  @override
  Future<ChatMessagesPageResult> getMessagesPage({
    required int conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    messagePageRequests.add(page);
    final start = (page - 1) * limit;
    if (start >= messages.length) {
      return ChatMessagesPageResult(
        messages: const [],
        total: messages.length,
        page: page,
        limit: limit,
      );
    }
    final end = (start + limit).clamp(0, messages.length);
    return ChatMessagesPageResult(
      messages: messages.sublist(start, end),
      total: messages.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ChatParticipants> getParticipants() async {
    return const ChatParticipants(
      patients: [],
      staffs: [
        ChatStaff(
          staffId: 7,
          userId: 2,
          staffCode: 'NV007',
          role: 'support',
          isActive: true,
        ),
      ],
    );
  }

  @override
  Future<ChatMessage> sendMessage({
    required int conversationId,
    String content = '',
    String type = 'text',
    String mediaUrl = '',
  }) async {
    sendMessageCalls++;
    throw StateError('REST sendMessage should not be called');
  }

  @override
  Future<void> markRead({required int conversationId}) async {
    markReadCalls++;
  }
}

ProviderContainer _container({
  required _FakeChatRepository fakeRepo,
  _FakeChatWebSocketService? fakeWs,
  _FakeUtilRepository? fakeUtil,
}) {
  final ws = fakeWs ?? _FakeChatWebSocketService();
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) => AuthNotifier(_NoopAuthRepository())
          ..setUser(
            const AuthUser(
              userId: 42,
              fullName: 'Patient',
              phoneNumber: '0900000001',
              token: 'token',
              role: 'patient',
            ),
          ),
      ),
      chatRepositoryProvider.overrideWithValue(fakeRepo),
      chatWebSocketServiceProvider.overrideWith((ref, conversationId) => ws),
      utilRepositoryProvider.overrideWithValue(
        fakeUtil ?? _FakeUtilRepository(),
      ),
    ],
  );
}

class _NoopAuthRepository extends AuthRepository {}

class _FakeChatWebSocketService extends ChatWebSocketService {
  _FakeChatWebSocketService() : super(1, tokenReader: () async => null);

  final List<Map<String, dynamic>> sentPayloads = [];
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  @override
  Future<void> connect() async {}

  @override
  void send(Map<String, dynamic> payload) {
    sentPayloads.add(payload);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

ChatRoom _room({
  required int id,
  int unreadCount = 0,
  String lastMessageAt = '2026-05-30T10:00:00Z',
}) {
  return ChatRoom(
    id: id,
    userId: 3,
    staffId: 7,
    status: 'open',
    name: 'Phòng $id',
    lastMessage: '',
    lastMessageAt: lastMessageAt,
    unreadCount: unreadCount,
    avatarUrl: '',
  );
}

ChatMessage _message({
  int id = 1,
  int roomId = 1,
  int senderId = 2,
  String senderType = 'user',
  String content = 'message',
  bool isRead = false,
  String createdAt = '2026-05-30T10:00:00Z',
}) {
  return ChatMessage(
    id: id,
    roomId: roomId,
    senderId: senderId,
    senderType: senderType,
    senderName: '',
    content: content,
    type: 'text',
    mediaUrl: '',
    isRead: isRead,
    isDeleted: false,
    createdAt: createdAt,
  );
}

class _FakeUtilRepository extends UtilRepository {
  int uploadCount = 0;

  @override
  Future<UploadResult> uploadFile(MultipartFile file) async {
    uploadCount++;
    return const UploadResult(
      fileUrl: '/uploads/test.png',
      fileName: 'test.png',
      fileSize: 12,
    );
  }
}
