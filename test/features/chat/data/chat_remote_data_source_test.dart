import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/chat/data/datasources/chat_remote_data_source.dart';

void main() {
  group('ChatRemoteDataSource', () {
    test('getParticipants parses success response', () async {
      final dataSource = ChatRemoteDataSource(
        dio: _dioReturning({
          'code': 1000,
          'message': 'OK',
          'data': {
            'patients': [
              {
                'user_id': 1,
                'full_name': 'Patient A',
                'phone_number': '0900000001',
                'user_type': 'patient',
              },
            ],
            'staffs': [
              {
                'staff_id': 7,
                'user_id': 8,
                'staff_code': 'NV007',
                'role': 'support',
                'is_active': true,
              },
            ],
          },
        }),
      );

      final participants = await dataSource.getParticipants();

      expect(participants.patients.single.fullName, 'Patient A');
      expect(participants.staffs.single.staffCode, 'NV007');
    });

    test('getParticipants throws on non-success code', () async {
      final dataSource = ChatRemoteDataSource(
        dio: _dioReturning({
          'code': 1001,
          'message': 'Không có quyền',
          'data': null,
        }),
      );

      expect(dataSource.getParticipants(), throwsException);
    });

    test(
      'closeRoom posts conversation id and accepts success response',
      () async {
        late Object? requestData;
        final dataSource = ChatRemoteDataSource(
          dio: _dioReturning({
            'code': 1000,
            'message': 'OK',
            'data': {'closed': true},
          }, onRequestData: (data) => requestData = data),
        );

        await dataSource.closeRoom(conversationId: 12);

        expect(requestData, {'conversation_id': 12});
      },
    );
  });
}

Dio _dioReturning(
  Map<String, dynamic> body, {
  void Function(Object? data)? onRequestData,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        onRequestData?.call(options.data);
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            data: body,
            statusCode: 200,
          ),
        );
      },
    ),
  );
  return dio;
}
