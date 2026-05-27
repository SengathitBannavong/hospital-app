import '../../data/models/chat_room.dart';

class ChatRoomsState {
  const ChatRoomsState({
    required this.rooms,
    required this.isLoading,
    required this.isRefreshing,
    required this.errorMessage,
    required this.totalUnread,
  });

  final List<ChatRoom> rooms;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final int totalUnread;

  factory ChatRoomsState.initial() => const ChatRoomsState(
    rooms: [],
    isLoading: true,
    isRefreshing: false,
    errorMessage: null,
    totalUnread: 0,
  );

  bool get hasRooms => rooms.isNotEmpty;

  ChatRoomsState copyWith({
    List<ChatRoom>? rooms,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    int? totalUnread,
    bool clearError = false,
  }) {
    return ChatRoomsState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      totalUnread: totalUnread ?? this.totalUnread,
    );
  }
}
