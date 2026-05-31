import '../../data/models/chat_message.dart';

class ChatMessagesState {
  const ChatMessagesState({
    required this.messages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isSending,
    required this.errorMessage,
    required this.hasMore,
    required this.page,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSending;
  final String? errorMessage;
  final bool hasMore;
  final int page;

  factory ChatMessagesState.initial() => const ChatMessagesState(
    messages: [],
    isLoading: true,
    isLoadingMore: false,
    isSending: false,
    errorMessage: null,
    hasMore: true,
    page: 1,
  );

  ChatMessagesState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSending,
    String? errorMessage,
    bool? hasMore,
    int? page,
    bool clearError = false,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}
