import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../network/token_repository.dart';

// Per-room WebSocket connection.
// Backend URL: GET /api/ws/chat?conversation_id=X&token=Y
class ChatWebSocketService {
  ChatWebSocketService(this._conversationId);

  final int _conversationId;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  bool _isConnected = false;
  bool _disposed = false;
  Timer? _reconnectTimer;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected || _disposed) return;
    final token = await TokenRepository.getToken();
    if (token == null) return;

    final baseUrl = AppConfig.baseUrl;
    final wsBase = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');

    // BASE_URL already includes /api/ — append ws/chat directly.
    final cleanBase = wsBase.endsWith('/') ? wsBase : '$wsBase/';
    final uri = Uri.parse('${cleanBase}ws/chat?conversation_id=$_conversationId&token=$token');

    try {
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _isConnected = true;

      _subscription = _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _onData(dynamic data) {
    try {
      final decoded = jsonDecode(data as String) as Map<String, dynamic>;
      _messageController.add(decoded);
    } catch (_) {}
  }

  void _onError(Object error) {
    _isConnected = false;
    if (!_disposed) _scheduleReconnect();
  }

  void _onDone() {
    _isConnected = false;
    if (!_disposed) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_disposed) connect();
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _isConnected = false;
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _messageController.close();
  }
}
