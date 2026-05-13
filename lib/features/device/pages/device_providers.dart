import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/core/network/models/api_response.dart';
import '../models/asset_station.dart';
import '../models/asset_booking_request.dart';
import '../models/report_broken_request.dart';
import '../models/request_staff_request.dart';
import '../models/release_asset_request.dart';

// Provider để lấy danh sách các trạm thiết bị (Asset Stations)
// Lấy dữ liệu qua GET /api/asset/asset_stations
final assetStationsProvider = FutureProvider<List<AssetStation>>((ref) async {
  final response = await ApiClient.instance.get(ApiEndpoints.assetStations);

  final apiResponse = ApiResponse<List<AssetStation>>.fromJson(
    response.data,
    (json) => (json as List)
        .map((e) => AssetStation.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  if (apiResponse.code == ApiResponseCodes.success &&
      apiResponse.data != null) {
    return apiResponse.data!;
  }
  throw Exception(apiResponse.message);
});

// Provider để quản lý Logic của thiết bị (Đặt chỗ, Trả, Báo hỏng)
final deviceServiceProvider = Provider((ref) => DeviceService());

class DeviceService {
  // Hàm đặt thiết bị (Wheelchair Booking)
  // POST /api/asset/book_asset
  Future<void> bookAsset(String assetId) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.bookAsset,
      data: AssetBookingRequest(assetId: assetId).toJson(),
    );

    final apiResponse = ApiResponse<dynamic>.fromJson(
      response.data,
      (json) => json,
    );
    if (apiResponse.code != ApiResponseCodes.success) {
      throw Exception(apiResponse.message);
    }
  }

  // Hàm trả thiết bị (Release Asset)
  // POST /api/asset/release_asset
  Future<void> releaseAsset(String assetId, String stationId) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.releaseAsset,
      data: ReleaseAssetRequest(
        assetId: assetId,
        stationId: stationId,
      ).toJson(),
    );

    final apiResponse = ApiResponse<dynamic>.fromJson(
      response.data,
      (json) => json,
    );
    if (apiResponse.code != ApiResponseCodes.success) {
      throw Exception(apiResponse.message);
    }
  }

  // Hàm báo cáo thiết bị hỏng (Report Broken)
  // POST /api/asset/report_broken_asset
  Future<void> reportBroken(String assetId, String reason) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.reportBrokenAsset,
      data: ReportBrokenRequest(assetId: assetId, reason: reason).toJson(),
    );

    final apiResponse = ApiResponse<dynamic>.fromJson(
      response.data,
      (json) => json,
    );
    if (apiResponse.code != ApiResponseCodes.success) {
      throw Exception(apiResponse.message);
    }
  }

  // Hàm yêu cầu nhân viên hỗ trợ (Request Staff)
  // POST /api/staff/request_staff
  Future<void> requestStaff(String assetId, String nodeId, String note) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.requestStaff,
      data: RequestStaffRequest(
        assetId: assetId,
        nodeId: nodeId,
        note: note,
      ).toJson(),
    );

    final apiResponse = ApiResponse<dynamic>.fromJson(
      response.data,
      (json) => json,
    );
    if (apiResponse.code != ApiResponseCodes.success) {
      throw Exception(apiResponse.message);
    }
  }

  // Hàm theo dõi vị trí thiết bị (Track Asset)
  // GET /api/asset/track_asset
  Future<dynamic> trackAsset(String assetId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.trackAsset,
      queryParameters: {'asset_id': assetId},
    );
    return response.data;
  }

  // Hàm kiểm tra tình trạng thiết bị (Asset Health)
  // GET /api/asset/asset_health
  Future<dynamic> getAssetHealth(String assetId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.assetHealth,
      queryParameters: {'asset_id': assetId},
    );
    return response.data;
  }

  // Hàm tìm kiếm xe lăn gần đó (Find Wheelchairs)
  // GET /api/asset/find_wheelchairs
  Future<dynamic> findWheelchairs(String nodeId, int radius) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.findWheelchairs,
      queryParameters: {'node_id': nodeId, 'radius': radius},
    );
    return response.data;
  }
}
