import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';

import '../models/medical_api_response.dart';
import '../models/medical_task.dart';
import '../models/prescription.dart';
import '../models/queue_status.dart';
import '../models/result_status.dart';
import '../models/room_open.dart';

class MedicalRepository {
  Future<List<MedicalTask>> getTasks() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.getTasks);

      final apiResponse = MedicalApiResponse<List<MedicalTask>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => MedicalTask.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<QueueStatus?> getQueue({required int poiId}) async {
    try {
      // ส่ง poi_id เป็น query เพื่อดูสถานะคิวของห้องนั้น
      final response = await ApiClient.instance.get(
        ApiEndpoints.medicalGetQueue,
        queryParameters: {'poi_id': poiId},
      );

      final apiResponse = MedicalApiResponse<QueueStatus>.fromJson(
        response.data,
        (json) => QueueStatus.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<bool> checkinRoom({required int treatmentId}) async {
    try {
      // ต้องส่ง treatment_id เพื่อ check-in ห้องตรวจ
      final response = await ApiClient.instance.post(
        ApiEndpoints.medicalCheckinRoom,
        data: {'treatment_id': treatmentId},
      );

      final apiResponse = MedicalApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return true;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<ResultStatus?> getResultStatus({required int treatmentId}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.medicalResultStatus,
        queryParameters: {'treatment_id': treatmentId},
      );

      final apiResponse = MedicalApiResponse<ResultStatus>.fromJson(
        response.data,
        (json) => ResultStatus.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<Prescription?> getPrescription() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.medicalGetPrescription,
      );

      final apiResponse = MedicalApiResponse<List<Prescription>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => Prescription.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        final prescriptions = apiResponse.data ?? [];
        return prescriptions.isNotEmpty ? prescriptions.first : null;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<bool> syncNow() async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.medicalSyncNow,
      );

      final apiResponse = MedicalApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return true;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<RoomOpen?> getRoomOpen({required int poiId}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.medicalRoomOpen,
        queryParameters: {'poi_id': poiId},
      );

      final apiResponse = MedicalApiResponse<RoomOpen>.fromJson(
        response.data,
        (json) => RoomOpen.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<bool> checkoutRoom({required int treatmentId}) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.medicalCheckoutRoom,
        data: {'treatment_id': treatmentId},
      );

      final apiResponse = MedicalApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return true;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<bool> cancelTask({required int treatmentId}) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.medicalCancelTask,
        data: {'treatment_id': treatmentId},
      );

      final apiResponse = MedicalApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return true;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<MedicalTask>> getHistory() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.medicalGetHistory,
      );

      final apiResponse = MedicalApiResponse<List<MedicalTask>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => MedicalTask.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] ?? e.message ?? 'Unknown error';
    }
    return e.message ?? 'Unknown error';
  }
}
