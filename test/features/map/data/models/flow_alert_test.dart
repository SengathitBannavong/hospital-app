import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/flow_alert.dart';

void main() {
  test('FlowAlert parses JSON with defaults', () {
    final alert = FlowAlert.fromJson({
      'id': 'flow-1',
      'message': 'High density',
      'location': 42,
    });

    expect(alert.id, 'flow-1');
    expect(alert.message, 'High density');
    expect(alert.location, 42);
    expect(alert.level, 'info');
  });
}
