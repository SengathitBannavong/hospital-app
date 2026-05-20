import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/models/location_source.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MapQrScannerPage extends ConsumerStatefulWidget {
  final int mapId;

  const MapQrScannerPage({super.key, required this.mapId});

  @override
  ConsumerState<MapQrScannerPage> createState() => _MapQrScannerPageState();
}

class _MapQrScannerPageState extends ConsumerState<MapQrScannerPage> {
  bool _handlingCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR code')),
      body: MobileScanner(onDetect: _handleDetection),
    );
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_handlingCode) return;
    final code = _firstPayload(capture);
    if (code == null) return;

    _handlingCode = true;
    try {
      final poi = await _resolvePoi(code);
      if (!mounted) return;
      if (poi == null) {
        _showFailure('No location found for $code');
        _handlingCode = false;
        return;
      }

      ref.read(navigationControllerProvider).stop();
      ref.read(userPositionProvider.notifier).state = poi.gridLocation;
      ref.read(locationSourceProvider.notifier).state = LocationSource.qr;
      Navigator.of(context).maybePop(true);
    } catch (_) {
      if (!mounted) return;
      _showFailure('QR lookup failed');
      _handlingCode = false;
    }
  }

  String? _firstPayload(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Future<MapPoi?> _resolvePoi(String code) async {
    final nodes = await ref.read(mapNodesProvider(widget.mapId).future);
    final local = _findPoiByCode(nodes, code);
    if (local != null) return local;

    final results = await ref
        .read(mapRepositoryProvider)
        .searchLocation(keyword: code, mapId: widget.mapId);
    return results.isEmpty ? null : results.first;
  }

  MapPoi? _findPoiByCode(List<MapPoi> pois, String code) {
    final normalizedCode = code.toLowerCase();
    for (final poi in pois) {
      if (poi.poiCode.toLowerCase() == normalizedCode) {
        return poi;
      }
    }
    return null;
  }

  void _showFailure(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
