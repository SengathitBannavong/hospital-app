import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message.dart';
import '../models/chat_participants.dart';
import '../models/chat_room.dart';

class ChatRepository {
  ChatRepository({ChatRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ChatRemoteDataSource();

  final ChatRemoteDataSource _remoteDataSource;

  Future<List<ChatRoom>> getRooms({int page = 1, int limit = 50}) =>
      _remoteDataSource.getRooms(page: page, limit: limit);

  Future<List<ChatMessage>> getMessages({
    required int conversationId,
    int page = 1,
    int limit = 30,
  }) => _remoteDataSource.getMessages(
    conversationId: conversationId,
    page: page,
    limit: limit,
  );

  Future<ChatParticipants> getParticipants() =>
      _remoteDataSource.getParticipants();

  Future<ChatMessage> sendMessage({
    required int conversationId,
    String content = '',
    String type = 'text',
    String mediaUrl = '',
  }) => _remoteDataSource.sendMessage(
    conversationId: conversationId,
    content: content,
    type: type,
    mediaUrl: mediaUrl,
  );

  Future<void> markRead({required int conversationId}) =>
      _remoteDataSource.markRead(conversationId: conversationId);

  Future<void> closeRoom({required int conversationId}) =>
      _remoteDataSource.closeRoom(conversationId: conversationId);
}
