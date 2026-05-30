import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('ChatMessagesNotifier', () {
    test('sendMessage inserts REST result and WS echo dedups by id', () async {
      final fakeRepo = _FakeChatRepository();
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeRepo),
          utilRepositoryProvider.overrideWithValue(_FakeUtilRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(chatMessagesProvider(1).notifier);
      await notifier.load();

      await notifier.sendMessage('hello');

      var state = container.read(chatMessagesProvider(1));
      expect(state.messages, hasLength(1));
      expect(state.messages.single.id, 99);
      expect(state.messages.single.content, 'hello');

      notifier.handleWebSocketMessage({
        'message_id': 99,
        'conversation_id': 1,
        'sender_id': 2,
        'sender_type': 'staff',
        'type': 'text',
        'text_content': 'hello',
        'created_at': '2026-05-30T10:00:00Z',
      });

      state = container.read(chatMessagesProvider(1));
      expect(state.messages, hasLength(1));
      expect(fakeRepo.sentContent, 'hello');
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
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeRepo),
          utilRepositoryProvider.overrideWithValue(_FakeUtilRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(chatMessagesProvider(1).notifier).load();

      final ids = container
          .read(chatMessagesProvider(1))
          .messages
          .map((message) => message.id)
          .toList();
      expect(ids, [4, 3, 2, 1]);
    });
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
  _FakeChatRepository({this.messages = const []})
    : super(
        remoteDataSource: ChatRemoteDataSource(
          dio: Dio(BaseOptions(baseUrl: 'https://example.test/api/')),
        ),
      );

  final List<ChatMessage> messages;
  String? sentContent;

  @override
  Future<List<ChatRoom>> getRooms({int page = 1, int limit = 50}) async {
    return const [
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
    ];
  }

  @override
  Future<List<ChatMessage>> getMessages({
    required int conversationId,
    int page = 1,
    int limit = 30,
  }) async {
    return messages;
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
    sentContent = content;
    return ChatMessage(
      id: 99,
      roomId: conversationId,
      senderId: 2,
      senderType: 'staff',
      senderName: '',
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      isRead: false,
      isDeleted: false,
      createdAt: '2026-05-30T10:00:00Z',
    );
  }
}

ChatMessage _message({
  int id = 1,
  int roomId = 1,
  int senderId = 2,
  String senderType = 'user',
  String createdAt = '2026-05-30T10:00:00Z',
}) {
  return ChatMessage(
    id: id,
    roomId: roomId,
    senderId: senderId,
    senderType: senderType,
    senderName: '',
    content: 'message $id',
    type: 'text',
    mediaUrl: '',
    isRead: false,
    isDeleted: false,
    createdAt: createdAt,
  );
}

class _FakeUtilRepository extends UtilRepository {
  @override
  Future<UploadResult> uploadFile(MultipartFile file) async {
    return const UploadResult(
      fileUrl: '/uploads/test.png',
      fileName: 'test.png',
      fileSize: 12,
    );
  }
}
