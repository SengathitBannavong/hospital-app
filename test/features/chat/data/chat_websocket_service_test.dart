import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/core/services/chat_websocket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'BASE_URL=https://example.test/api/');
  });

  group('ChatWebSocketService.send', () {
    test('queues while disconnected and flushes after connect', () async {
      final channel = _FakeWebSocketChannel();
      final service = ChatWebSocketService(
        1,
        connector: (_) => channel,
        tokenReader: () async => 'token',
      )..send({'type': 'text', 'text_content': 'queued'});
      expect(channel.sink.sent, isEmpty);

      await service.connect();

      expect(channel.sink.sent, hasLength(1));
      expect(jsonDecode(channel.sink.sent.single), {
        'type': 'text',
        'text_content': 'queued',
      });
      await service.dispose();
    });

    test('sends immediately when connected', () async {
      final channel = _FakeWebSocketChannel();
      final service = ChatWebSocketService(
        1,
        connector: (_) => channel,
        tokenReader: () async => 'token',
      );
      await service.connect();

      service.send({'type': 'image', 'media_url': '/uploads/a.png'});

      expect(channel.sink.sent, hasLength(1));
      expect(jsonDecode(channel.sink.sent.single), {
        'type': 'image',
        'media_url': '/uploads/a.png',
      });
      await service.dispose();
    });

    test('accepts wrapped inbound message frames', () async {
      final channel = _FakeWebSocketChannel();
      final service = ChatWebSocketService(
        1,
        connector: (_) => channel,
        tokenReader: () async => 'token',
      );
      await service.connect();

      channel.addInbound(
        jsonEncode({
          'type': 'message',
          'data': {'message_id': 9, 'text_content': 'hello'},
        }),
      );

      await expectLater(
        service.messages,
        emits({'message_id': 9, 'text_content': 'hello'}),
      );
      await service.dispose();
    });
  });
}

class _FakeWebSocketChannel implements WebSocketChannel {
  final _controller = StreamController<dynamic>();
  @override
  final _FakeWebSocketSink sink = _FakeWebSocketSink();

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  @override
  Future<void> get ready async {}

  @override
  Stream<dynamic> get stream => _controller.stream;

  void addInbound(String event) {
    _controller.add(event);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWebSocketSink implements WebSocketSink {
  final List<String> sent = [];
  final _done = Completer<void>();

  @override
  Future<void> get done => _done.future;

  @override
  void add(dynamic event) {
    sent.add(event as String);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream stream) async {
    await for (final event in stream) {
      add(event);
    }
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    if (!_done.isCompleted) _done.complete();
  }
}
