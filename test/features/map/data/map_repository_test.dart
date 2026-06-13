import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.testLoad(fileInput: 'BASE_URL=https://example.test/api/');
  });

  test('rateRoute sends is_accurate and omits empty comment', () async {
    final captured = <RequestOptions>[];
    final interceptor = _CaptureInterceptor(captured);
    ApiClient.instance.interceptors.insert(0, interceptor);
    addTearDown(() => ApiClient.instance.interceptors.remove(interceptor));

    await MapRepository().rateRoute(
      routeId: 'route-1',
      rating: 4,
      comment: '',
      isAccurate: false,
    );

    expect(captured, hasLength(1));
    expect(captured.single.path, ApiEndpoints.routeRate);
    expect(captured.single.data, {
      'route_id': 'route-1',
      'rating': 4,
      'is_accurate': false,
    });
  });

  test('rateRoute omits is_accurate when null', () async {
    final captured = <RequestOptions>[];
    final interceptor = _CaptureInterceptor(captured);
    ApiClient.instance.interceptors.insert(0, interceptor);
    addTearDown(() => ApiClient.instance.interceptors.remove(interceptor));

    await MapRepository().rateRoute(
      routeId: 'route-1',
      rating: 5,
      comment: 'Good route',
    );

    expect(captured.single.data, {
      'route_id': 'route-1',
      'rating': 5,
      'comment': 'Good route',
    });
  });

  test('cancelRoute posts route_id to route/cancel', () async {
    final captured = <RequestOptions>[];
    final interceptor = _CaptureInterceptor(captured);
    ApiClient.instance.interceptors.insert(0, interceptor);
    addTearDown(() => ApiClient.instance.interceptors.remove(interceptor));

    await MapRepository().cancelRoute(routeId: 'route-99');

    expect(captured, hasLength(1));
    expect(captured.single.path, ApiEndpoints.routeCancel);
    expect(captured.single.data, {'route_id': 'route-99'});
  });

  test('passNode posts route_id and grid_location', () async {
    final captured = <RequestOptions>[];
    final interceptor = _CaptureInterceptor(captured);
    ApiClient.instance.interceptors.insert(0, interceptor);
    addTearDown(() => ApiClient.instance.interceptors.remove(interceptor));

    await MapRepository().passNode(routeId: 'route-7', gridLocation: 123);

    expect(captured, hasLength(1));
    expect(captured.single.path, ApiEndpoints.routePassNode);
    expect(captured.single.data, {'route_id': 'route-7', 'grid_location': 123});
  });
}

class _CaptureInterceptor extends Interceptor {
  _CaptureInterceptor(this.requests);

  final List<RequestOptions> requests;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: const {
          'code': ApiResponseCodes.success,
          'message': 'ok',
          'data': null,
        },
      ),
    );
  }
}
