// Design tokens ported from "Fedayn's Auth Flow.dc.html".
//
// Colours split in two:
//   * AppColors  — brand constants that are identical in both themes (the
//                  accent orange, status colours, the navy hero surface).
//   * AppPalette — surfaces and text, which flip between light and dark.
//                  Read them from a BuildContext: `p.field`.

import 'package:flutter/material.dart';

/// Constantes de marque : ce qui ne change pas avec le thème.
///
/// L'accent et les couleurs de statut n'y sont plus. Elles dépendent du fond
/// sur lequel elles se posent, et un ocre unique ne peut pas rester lisible à
/// la fois sur sable et sur nuit — elles vivent dans [AppPalette].
class AppColors {
  /// Le héros de l'écran d'accueil, sombre dans les deux thèmes.
  /// Nuit Majorelle plutôt que marine générique.
  static const navyDark = Color(0xFF101120);

  /// Fond du scanner de documents : presque noir, pour que la pièce ressorte.
  static const scannerBg = Color(0xFF0B0F14);
}

class AppRadius {
  static const field = 14.0;
  static const card = 16.0;
  static const small = 12.0;
  static const pill = 999.0;
}

/// Tout ce qui change entre le clair et le sombre.
///
/// L'accent et les couleurs de statut y sont désormais aussi : un ocre assez
/// foncé pour être lisible sur fond sable est trop sombre sur fond nuit, donc
/// une constante unique ne peut pas satisfaire AA dans les deux thèmes.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.page,
    required this.surface,
    required this.field,
    required this.chipBg,
    required this.searchBg,
    required this.infoBg,
    required this.border,
    required this.cardBorder,
    required this.divider,
    required this.navy,
    required this.muted,
    required this.mutedLight,
    required this.labelIdle,
    required this.infoText,
    required this.silver,
    required this.brandNavy,
    required this.grayDot,
    required this.accent,
    required this.accentHover,
    required this.onAccent,
    required this.green,
    required this.amber,
    required this.red,
    required this.star,
    required this.greenSurface,
    required this.amberSurface,
    required this.redSurface,
    required this.redBorder,
    required this.accentSurface,
    required this.accentSurfaceHover,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.elevated,
    required this.toastBg,
    required this.onToast,
  });

  /// Fond d'écran.
  final Color page;
  /// Cartes et feuilles.
  final Color surface;
  /// Remplissage des champs.
  final Color field;
  final Color chipBg;
  final Color searchBg;
  final Color infoBg;
  final Color border;
  final Color cardBorder;
  final Color divider;
  /// Texte principal.
  final Color navy;
  final Color muted;
  final Color mutedLight;
  final Color labelIdle;
  final Color infoText;
  final Color silver;
  final Color brandNavy;
  final Color grayDot;
  /// Terre brûlée le jour, ocre clair la nuit.
  final Color accent;
  final Color accentHover;
  /// Texte posé sur accent.
  final Color onAccent;
  /// Disponible.
  final Color green;
  /// Bientôt disponible.
  final Color amber;
  /// En location, erreurs.
  final Color red;
  /// Étoiles de notation.
  final Color star;
  final Color greenSurface;
  final Color amberSurface;
  final Color redSurface;
  final Color redBorder;
  final Color accentSurface;
  final Color accentSurfaceHover;
  /// Bleu Majorelle en clair.
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color elevated;
  final Color toastBg;
  final Color onToast;

  /// Palette claire : sable chaulé, terre brûlée, bleu Majorelle.
  static const light = AppPalette(
    page: Color(0xFFFBF8F4),
    surface: Color(0xFFFFFFFF),
    field: Color(0xFFF4F1EC),
    chipBg: Color(0xFFEDE8E1),
    searchBg: Color(0xFFF4F1EC),
    infoBg: Color(0xFFF1EFEA),
    border: Color(0xFFE3DDD4),
    cardBorder: Color(0xFFEDE8E1),
    divider: Color(0xFFF2EEE8),
    navy: Color(0xFF1B1C3A),
    muted: Color(0xFF5F6275),
    mutedLight: Color(0xFF6E7185),
    labelIdle: Color(0xFF65687B),
    infoText: Color(0xFF4E5163),
    silver: Color(0xFF6E7185),
    brandNavy: Color(0xFF1B1C3A),
    grayDot: Color(0xFFB9B3AA),
    accent: Color(0xFFA8501B),
    accentHover: Color(0xFF924517),
    onAccent: Color(0xFFFFFFFF),
    green: Color(0xFF116B45),
    amber: Color(0xFF8A5A00),
    red: Color(0xFFA32219),
    star: Color(0xFF9A7B0A),
    greenSurface: Color(0xFFE4F1EA),
    amberSurface: Color(0xFFF7EEDC),
    redSurface: Color(0xFFF8E7E5),
    redBorder: Color(0xFFEFD3CF),
    accentSurface: Color(0xFFFBEEE4),
    accentSurfaceHover: Color(0xFFF6E2D2),
    inverseSurface: Color(0xFF3A34A8),
    onInverseSurface: Color(0xFFFFFFFF),
    elevated: Color(0xFFFFFFFF),
    toastBg: Color(0xFF1B1C3A),
    onToast: Color(0xFFFFFFFF),
  );

  /// Palette sombre. Les surfaces sont teintées Majorelle plutôt que grises,
  /// et l'accent s'éclaircit au lieu de garder sa valeur du mode clair.
  static const dark = AppPalette(
    page: Color(0xFF101120),
    surface: Color(0xFF1A1B2E),
    field: Color(0xFF212239),
    chipBg: Color(0xFF282A45),
    searchBg: Color(0xFF212239),
    infoBg: Color(0xFF1C1E33),
    border: Color(0xFF33355A),
    cardBorder: Color(0xFF2B2D4A),
    divider: Color(0xFF262845),
    navy: Color(0xFFECEBF5),
    muted: Color(0xFFA6A8C0),
    mutedLight: Color(0xFF8A8DA8),
    labelIdle: Color(0xFF8A8DA8),
    infoText: Color(0xFFB6B8CC),
    silver: Color(0xFF8A8DA8),
    brandNavy: Color(0xFFECEBF5),
    grayDot: Color(0xFF4E5170),
    accent: Color(0xFFE9A06A),
    accentHover: Color(0xFFF2B183),
    onAccent: Color(0xFF101120),
    green: Color(0xFF4FD196),
    amber: Color(0xFFE6B65C),
    red: Color(0xFFF08A80),
    star: Color(0xFFE6C15C),
    greenSurface: Color(0xFF12301F),
    amberSurface: Color(0xFF332612),
    redSurface: Color(0xFF331A18),
    redBorder: Color(0xFF5A2E2A),
    accentSurface: Color(0xFF33220F),
    accentSurfaceHover: Color(0xFF3F2B14),
    inverseSurface: Color(0xFFECEBF5),
    onInverseSurface: Color(0xFF101120),
    elevated: Color(0xFF33355A),
    toastBg: Color(0xFF2B2D4A),
    onToast: Color(0xFFECEBF5),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      page: c(page, other.page),
      surface: c(surface, other.surface),
      field: c(field, other.field),
      chipBg: c(chipBg, other.chipBg),
      searchBg: c(searchBg, other.searchBg),
      infoBg: c(infoBg, other.infoBg),
      border: c(border, other.border),
      cardBorder: c(cardBorder, other.cardBorder),
      divider: c(divider, other.divider),
      navy: c(navy, other.navy),
      muted: c(muted, other.muted),
      mutedLight: c(mutedLight, other.mutedLight),
      labelIdle: c(labelIdle, other.labelIdle),
      infoText: c(infoText, other.infoText),
      silver: c(silver, other.silver),
      brandNavy: c(brandNavy, other.brandNavy),
      grayDot: c(grayDot, other.grayDot),
      accent: c(accent, other.accent),
      accentHover: c(accentHover, other.accentHover),
      onAccent: c(onAccent, other.onAccent),
      green: c(green, other.green),
      amber: c(amber, other.amber),
      red: c(red, other.red),
      star: c(star, other.star),
      greenSurface: c(greenSurface, other.greenSurface),
      amberSurface: c(amberSurface, other.amberSurface),
      redSurface: c(redSurface, other.redSurface),
      redBorder: c(redBorder, other.redBorder),
      accentSurface: c(accentSurface, other.accentSurface),
      accentSurfaceHover: c(accentSurfaceHover, other.accentSurfaceHover),
      inverseSurface: c(inverseSurface, other.inverseSurface),
      onInverseSurface: c(onInverseSurface, other.onInverseSurface),
      elevated: c(elevated, other.elevated),
      toastBg: c(toastBg, other.toastBg),
      onToast: c(onToast, other.onToast),
    );
  }
}

extension PaletteAccess on BuildContext {
  /// The active light/dark palette.
  AppPalette get p => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

/// Poppins for headings, Inter for everything else — as specified in the design.
///
/// `color` is nullable on purpose: leaving it off inherits the theme's default
/// text colour, so body copy flips with the theme without every call site
/// naming a colour.
class AppText {
  static TextStyle heading(double size, {Color? color, FontWeight weight = FontWeight.w600, double? height}) =>
      TextStyle(fontFamily: 'Poppins', fontSize: size, color: color, fontWeight: weight, height: height);

  static TextStyle body(double size,
          {Color? color, FontWeight weight = FontWeight.w400, double? height, double? letterSpacing}) =>
      TextStyle(
          fontFamily: 'Inter',
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing);

  /// The small all-caps section label used above field groups and steppers.
  static TextStyle overline({Color? color}) => TextStyle(
      fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 10 * 0.14, color: color);
}

ThemeData buildAppTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  final base = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    scaffoldBackgroundColor: p.page,
    canvasColor: p.page,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: brightness,
      primary: p.accent,
      secondary: p.accent,
      surface: p.surface,
    ),
    extensions: [p],
    // Body copy with no explicit colour inherits this.
    textTheme: base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: p.navy,
      displayColor: p.navy,
    ),
    dividerColor: p.divider,
    splashFactory: InkRipple.splashFactory,
    // Material 3 derives the off-state track from the seed, which against an
    // orange seed comes out pink-brown and reads as a colour the design never
    // uses. Pin every state to palette tokens instead.
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.onAccent : p.surface,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.accent : p.chipBg,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.accent : p.border,
      ),
      // The default outline thickens on the unselected track; the design's
      // switches are flat.
      trackOutlineWidth: const WidgetStatePropertyAll(1.5),
    ),
  );
}
