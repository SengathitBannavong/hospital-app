import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/chat/data/models/chat_message.dart';
import 'package:hospital_app/features/chat/data/models/chat_participants.dart';
import 'package:hospital_app/features/chat/data/models/chat_room.dart';

void main() {
  group('ChatMessage.fromJson', () {
    test('parses tolerant message fields including media/read flags', () {
      final message = ChatMessage.fromJson({
        'message_id': '42',
        'conversation_id': 7.0,
        'sender_id': '9',
        'sender_type': 'staff',
        'text_content': 'Xin chào',
        'type': 'image',
        'media_url': '/uploads/a.png',
        'is_read': 1,
        'is_deleted': 'false',
        'created_at': '2026-05-30T10:00:00Z',
      });

      expect(message.id, 42);
      expect(message.roomId, 7);
      expect(message.senderId, 9);
      expect(message.senderType, 'staff');
      expect(message.senderName, '');
      expect(message.content, 'Xin chào');
      expect(message.type, 'image');
      expect(message.mediaUrl, '/uploads/a.png');
      expect(message.isRead, isTrue);
      expect(message.isDeleted, isFalse);
    });
  });

  group('ChatRoom.fromJson', () {
    test('parses tolerant room fields', () {
      final room = ChatRoom.fromJson({
        'conversation_id': '11',
        'topic': 'Hỗ trợ',
        'last_message': 'Tin mới',
        'last_message_at': '2026-05-30T10:00:00Z',
        'unread_count': '3',
        'avatar_url': '/uploads/avatar.png',
        'user_id': '5',
        'staff_id': 7,
        'status': 'closed',
      });

      expect(room.id, 11);
      expect(room.userId, 5);
      expect(room.staffId, 7);
      expect(room.status, 'closed');
      expect(room.name, 'Hỗ trợ');
      expect(room.lastMessage, 'Tin mới');
      expect(room.unreadCount, 3);
      expect(room.avatarUrl, '/uploads/avatar.png');
    });
  });

  group('ChatParticipants.fromJson', () {
    test('parses patients and staff lists', () {
      final participants = ChatParticipants.fromJson({
        'patients': [
          {
            'user_id': '5',
            'full_name': 'Nguyen Van A',
            'phone_number': '0900000001',
            'user_type': 'patient',
            'avatar_url': '',
          },
        ],
        'staffs': [
          {
            'staff_id': '2',
            'user_id': 9,
            'staff_code': 'NV002',
            'role': 'doctor',
            'is_active': 'true',
          },
        ],
      });

      expect(participants.patients.single.userId, 5);
      expect(participants.patients.single.fullName, 'Nguyen Van A');
      expect(participants.patients.single.avatarUrl, isNull);
      expect(participants.staffs.single.staffId, 2);
      expect(participants.staffs.single.userId, 9);
      expect(participants.staffs.single.isActive, isTrue);
    });
  });
}
