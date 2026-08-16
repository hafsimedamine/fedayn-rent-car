import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/state/app_state.dart';

void main() {
  test('recommended keeps the curated fleet order', () {
    final s = AppState()..setSort(SortMode.recommended);
    expect(s.visibleCars.map((c) => c.id).toList(), kCars.map((c) => c.id).toList());
  });

  test('price sorts both ways', () {
    final s = AppState()..setSort(SortMode.priceAsc);
    var prices = s.visibleCars.map((c) => c.price).toList();
    expect(prices, orderedEquals([...prices]..sort()));
    expect(prices.first, 250); // Dacia Sandero

    s.setSort(SortMode.priceDesc);
    prices = s.visibleCars.map((c) => c.price).toList();
    expect(prices.first, 1800); // Range Rover Evoque
    expect(prices.first, greaterThan(prices.last));
  });

  test('rating and popularity rank correctly', () {
    final s = AppState()..setSort(SortMode.rating);
    final ratings = s.visibleCars.map((c) => double.parse(c.rating)).toList();
    for (var i = 1; i < ratings.length; i++) {
      expect(ratings[i - 1], greaterThanOrEqualTo(ratings[i]));
    }

    s.setSort(SortMode.popular);
    final reviews = s.visibleCars.map((c) => c.reviews).toList();
    expect(reviews.first, 210); // Dacia Duster, most reviewed
    for (var i = 1; i < reviews.length; i++) {
      expect(reviews[i - 1], greaterThanOrEqualTo(reviews[i]));
    }
  });

  test('newest ranks by vehicle age', () {
    final s = AppState()..setSort(SortMode.newest);
    final ages = s.visibleCars.map((c) => kSpecs[c.id]?.years ?? 99).toList();
    for (var i = 1; i < ages.length; i++) {
      expect(ages[i - 1], lessThanOrEqualTo(ages[i]));
    }
  });

  test('sorting composes with the category chip', () {
    final s = AppState()
      ..setChip('SUV')
      ..setSort(SortMode.priceDesc);

    final cars = s.visibleCars;
    expect(cars, isNotEmpty);
    expect(cars.every((c) => c.filters.contains('SUV')), isTrue);
    expect(cars.first.price, greaterThanOrEqualTo(cars.last.price));
  });

  test('every mode has a label and a hint', () {
    for (final m in SortMode.values) {
      expect(m.label, isNotEmpty);
      expect(m.hint, isNotEmpty);
    }
  });
}
