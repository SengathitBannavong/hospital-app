import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';

class UtilitySnapshot {
  const UtilitySnapshot({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
}

class UtilRepository {
  Future<UtilitySnapshot> getWeather() async {
    final data = await _fetchData(ApiEndpoints.weather);
    final temperature = _firstString(data, [
      'temperature',
      'temp',
      'degree',
      'degrees',
      'value',
    ]);
    final summary = _firstString(data, [
      'condition',
      'description',
      'weather',
      'status',
      'message',
    ]);
    final location = _firstString(data, ['location', 'city', 'area', 'name']);

    final displayValue = temperature.isEmpty
        ? 'Đang cập nhật'
        : '$temperature°C';
    final displaySubtitle = [
      summary,
      location,
    ].where((value) => value.isNotEmpty).join(' • ');

    return UtilitySnapshot(
      title: 'Thời tiết',
      value: displayValue,
      subtitle: displaySubtitle.isEmpty
          ? 'Dữ liệu thời tiết từ hệ thống'
          : displaySubtitle,
      icon: Icons.wb_sunny_outlined,
    );
  }

  Future<UtilitySnapshot> getParking() async {
    final data = await _fetchData(ApiEndpoints.parking);
    final available = _firstString(data, [
      'available',
      'available_slots',
      'slots_available',
      'free',
      'count',
      'value',
    ]);
    final total = _firstString(data, ['total', 'capacity', 'max', 'limit']);
    final status = _firstString(data, ['status', 'message', 'description']);

    final displayValue = available.isEmpty ? 'Đang cập nhật' : '$available chỗ';
    final displaySubtitle = [
      if (total.isNotEmpty) 'Tổng $total chỗ',
      if (status.isNotEmpty) status,
    ].join(' • ');

    return UtilitySnapshot(
      title: 'Bãi đỗ xe',
      value: displayValue,
      subtitle: displaySubtitle.isEmpty
          ? 'Dữ liệu bãi đỗ từ hệ thống'
          : displaySubtitle,
      icon: Icons.local_parking_outlined,
    );
  }

  Future<Map<String, dynamic>> _fetchData(String endpoint) async {
    try {
      final response = await ApiClient.instance.get(endpoint);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final nested = data['data'];
        if (nested is Map<String, dynamic>) {
          return nested;
        }

        return data;
      }

      return <String, dynamic>{'value': data};
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message'] ??
            error.message ??
            'Không thể tải dữ liệu tiện ích.',
      );
    }
  }

  String _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }

    return '';
  }
}
