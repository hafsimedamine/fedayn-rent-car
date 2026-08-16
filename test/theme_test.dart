// Dark mode: the toggle must flip the palette, and every surface/text token
// must actually differ between the two themes (a token left the same in both
// is the bug this guards).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';

void main() {
  test('state toggles theme mode', () {
    final s = AppState();
    expect(s.isDarkMode, isFalse);
    expect(s.themeMode, ThemeMode.light);

    s.setDarkMode(true);
    expect(s.isDarkMode, isTrue);
    expect(s.themeMode, ThemeMode.dark);

    s.setDarkMode(false);
    expect(s.themeMode, ThemeMode.light);
  });

  test('both themes carry a palette, and they differ', () {
    final light = buildAppTheme(Brightness.light).extension<AppPalette>();
    final dark = buildAppTheme(Brightness.dark).extension<AppPalette>();

    expect(light, isNotNull);
    expect(dark, isNotNull);
    expect(light!.page, isNot(dark!.page));
    expect(light.navy, isNot(dark.navy));
    expect(light.surface, isNot(dark.surface));
  });

  test('dark surfaces are dark and dark body text is light', () {
    final dark = buildAppTheme(Brightness.dark).extension<AppPalette>()!;

    expect(dark.page.computeLuminance(), lessThan(0.1));
    expect(dark.surface.computeLuminance(), lessThan(0.15));
    expect(dark.navy.computeLuminance(), greaterThan(0.5));
    // The filled "primary dark" affordance inverts against body text, so a
    // white glyph on it would vanish — they must contrast with each other.
    expect(
      (dark.inverseSurface.computeLuminance() - dark.onInverseSurface.computeLuminance()).abs(),
      greaterThan(0.4),
    );
  });

  test('body text contrasts with its background in both themes', () {
    for (final b in Brightness.values) {
      final p = buildAppTheme(b).extension<AppPalette>()!;
      for (final pair in [
        (p.navy, p.page),
        (p.navy, p.surface),
        (p.muted, p.surface),
        // The selected segment in a segmented control...
        (p.navy, p.elevated),
        // ...and the toast, both of which regressed by using body-text navy
        // as a background.
        (p.onInverseSurface, p.inverseSurface),
        (p.onToast, p.toastBg),
      ]) {
        final delta = (pair.$1.computeLuminance() - pair.$2.computeLuminance()).abs();
        expect(delta, greaterThan(0.15), reason: '$b: ${pair.$1} on ${pair.$2} is too low contrast');
      }
    }
  });
}
