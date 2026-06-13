import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/presentation/pages/route_rating_page.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

void main() {
  testWidgets('submits rating with comment and accuracy flag', (tester) async {
    final repository = _RatingRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [mapRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: RouteRatingPage(routeId: 'server-route-1'),
        ),
      ),
    );

    await tester.tap(find.byTooltip('4 sao'));
    await tester.enterText(
      find.byType(TextField),
      'Avoided the crowded hallway.',
    );
    await tester.tap(find.text('Không'));
    await tester.pump();
    await tester.tap(find.text('Gửi đánh giá'));
    await tester.pump();

    expect(repository.calls, 1);
    expect(repository.routeId, 'server-route-1');
    expect(repository.rating, 4);
    expect(repository.comment, 'Avoided the crowded hallway.');
    expect(repository.isAccurate, isFalse);
  });
}

class _RatingRepository extends MapRepository {
  int calls = 0;
  String? routeId;
  int? rating;
  String? comment;
  bool? isAccurate;

  @override
  Future<void> rateRoute({
    required String routeId,
    required int rating,
    String? comment,
    bool? isAccurate,
  }) async {
    calls++;
    this.routeId = routeId;
    this.rating = rating;
    this.comment = comment;
    this.isAccurate = isAccurate;
  }
}
