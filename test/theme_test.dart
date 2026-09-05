// Dark mode: the toggle must flip the palette, and every surface/text token
// must actually differ between the two themes (a token left the same in both
// is the bug this guards).

import 'dart:math' as math;

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

  test('chaque texte atteint le seuil WCAG AA de 4,5:1', () {
    // L'ancien contrôle comparait des luminances relatives (« écart > 0,15 »),
    // ce qui n'est pas un ratio WCAG : l'ancien accent #E1863B le passait alors
    // qu'il plafonnait à 2,74:1 sur blanc.
    for (final b in Brightness.values) {
      final p = buildAppTheme(b).extension<AppPalette>()!;
      final paires = <String, (Color, Color)>{
        'texte / page': (p.navy, p.page),
        'texte / carte': (p.navy, p.surface),
        'texte secondaire / carte': (p.muted, p.surface),
        'texte tertiaire / carte': (p.mutedLight, p.surface),
        'libellé de champ / champ': (p.labelIdle, p.field),
        'texte d\'info / fond d\'info': (p.infoText, p.infoBg),
        'texte / segment sélectionné': (p.navy, p.elevated),
        'texte de toast / toast': (p.onToast, p.toastBg),
        'texte sur surface inversée': (p.onInverseSurface, p.inverseSurface),
        'prix en MAD / page': (p.accent, p.page),
        'prix en MAD / carte': (p.accent, p.surface),
        'texte sur bouton accent': (p.onAccent, p.accent),
        'badge disponible': (p.green, p.greenSurface),
        'badge bientôt': (p.amber, p.amberSurface),
        'badge en location': (p.red, p.redSurface),
      };

      paires.forEach((nom, paire) {
        final r = contrasteWcag(paire.$1, paire.$2);
        expect(r, greaterThanOrEqualTo(4.5),
            reason: '$b — $nom : ${r.toStringAsFixed(2)}:1, sous le seuil AA');
      });
    }
  });

  test('l\'encre posée sur une couleur de statut reste lisible', () {
    // Les widgets écrivaient Colors.white en dur sur l'accent et sur les
    // couleurs de statut. En mode sombre celles-ci sont claires : le blanc y
    // tombait à 2,16:1. La page fait une encre correcte dans les deux sens.
    for (final b in Brightness.values) {
      final p = buildAppTheme(b).extension<AppPalette>()!;
      for (final entry in {
        'accent': p.accent,
        'vert': p.green,
        'ambre': p.amber,
        'rouge': p.red,
      }.entries) {
        expect(contrasteWcag(p.page, entry.value), greaterThanOrEqualTo(4.5),
            reason: '$b — encre sur ${entry.key}');
      }
    }
  });

  test('l\'accent change entre les deux thèmes', () {
    // Un ocre assez foncé pour être lisible sur sable est trop sombre sur nuit :
    // c'est pourquoi l'accent a quitté AppColors pour la palette.
    final clair = buildAppTheme(Brightness.light).extension<AppPalette>()!;
    final sombre = buildAppTheme(Brightness.dark).extension<AppPalette>()!;
    expect(clair.accent, isNot(sombre.accent));
    expect(clair.onAccent, isNot(sombre.onAccent));
  });

  test('les icônes de statut restent visibles (seuil 3:1)', () {
    for (final b in Brightness.values) {
      final p = buildAppTheme(b).extension<AppPalette>()!;
      // Une étoile de notation est un pictogramme, pas du texte : le seuil
      // applicable est celui des éléments non textuels.
      expect(contrasteWcag(p.star, p.surface), greaterThanOrEqualTo(3.0),
          reason: '$b — étoile sur carte');
    }
  });
}

/// Ratio de contraste WCAG 2.1 entre deux couleurs opaques.
double contrasteWcag(Color a, Color b) {
  double canal(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) => 0.2126 * canal(c.r) + 0.7152 * canal(c.g) + 0.0722 * canal(c.b);
  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
