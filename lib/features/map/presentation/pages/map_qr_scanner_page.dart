import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
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
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.mapScanQrTitle)),
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleDetection),
          if (_message != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
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
        _showFailure(appL10n.mapQrNoLocation(code));
        _handlingCode = false;
        return;
      }

      ref.read(navigationControllerProvider).stop();
      ref.read(userPositionProvider.notifier).state = poi.gridLocation;
      ref.read(locationSourceProvider.notifier).state = LocationSource.qr;
      Navigator.of(context).maybePop(true);
    } catch (_) {
      if (!mounted) return;
      _showFailure(appL10n.mapQrLookupFailed);
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
    setState(() => _message = message);
  }
}
