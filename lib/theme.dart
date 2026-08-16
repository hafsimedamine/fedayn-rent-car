// Design tokens ported from "Fedayn's Auth Flow.dc.html".
//
// Colours split in two:
//   * AppColors  — brand constants that are identical in both themes (the
//                  accent orange, status colours, the navy hero surface).
//   * AppPalette — surfaces and text, which flip between light and dark.
//                  Read them from a BuildContext: `context.p.field`.

import 'package:flutter/material.dart';

/// Brand constants. These do not change with the theme.
class AppColors {
  static const navyDark = Color(0xFF0A1B2E); // welcome hero / dark surfaces
  static const accent = Color(0xFFE1863B);
  static const accentHover = Color(0xFFEA9550);
  static const scannerBg = Color(0xFF0B0F14);

  // Status colours read the same on either background.
  static const green = Color(0xFF2E9E5B);
  static const red = Color(0xFFD64545);
  static const amber = Color(0xFFB7791F);
  static const star = Color(0xFFE1B23B);
}

class AppRadius {
  static const field = 14.0;
  static const card = 16.0;
  static const small = 12.0;
  static const pill = 999.0;
}

/// Everything that differs between light and dark.
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
    required this.promoA,
    required this.promoATile,
    required this.promoB,
    required this.promoBTile,
  });

  final Color page; // screen background
  final Color surface; // cards and sheets
  final Color field; // input fill
  final Color chipBg;
  final Color searchBg;
  final Color infoBg;
  final Color border;
  final Color cardBorder;
  final Color divider;

  final Color navy; // primary text
  final Color muted;
  final Color mutedLight;
  final Color labelIdle;
  final Color infoText;
  final Color silver;
  final Color brandNavy;
  final Color grayDot;

  final Color greenSurface;
  final Color amberSurface;
  final Color redSurface;
  final Color redBorder;
  final Color accentSurface;
  final Color accentSurfaceHover;

  /// Filled "primary dark" affordances — the search filter button, the Apply
  /// button, small filled actions. Distinct from [navy], which is body text and
  /// therefore inverts the other way in dark mode.
  final Color inverseSurface;
  final Color onInverseSurface;

  /// Sits one step above [chipBg] — the selected segment in a segmented
  /// control. In dark mode that means lighter than the track, not darker.
  final Color elevated;

  /// Toast plate. Material's convention would flip this to a light surface in
  /// dark mode; the design keeps it dark so a notification never flashes a
  /// bright panel over a dark screen.
  final Color toastBg;
  final Color onToast;

  final Color promoA;
  final Color promoATile;
  final Color promoB;
  final Color promoBTile;

  static const light = AppPalette(
    page: Color(0xFFFDFDFC),
    surface: Color(0xFFFFFFFF),
    field: Color(0xFFF7F8FA),
    chipBg: Color(0xFFF1F3F6),
    searchBg: Color(0xFFF4F6F9),
    infoBg: Color(0xFFF1F5F9),
    border: Color(0xFFE6E9EF),
    cardBorder: Color(0xFFEEF1F5),
    divider: Color(0xFFF3F5F8),
    navy: Color(0xFF0D2137),
    muted: Color(0xFF77808F),
    mutedLight: Color(0xFF9AA3B2),
    labelIdle: Color(0xFF8A94A6),
    infoText: Color(0xFF5B6675),
    silver: Color(0xFF8A97A6),
    brandNavy: Color(0xFF0F2A3D),
    grayDot: Color(0xFFB7BFCA),
    greenSurface: Color(0xFFEAF6EE),
    amberSurface: Color(0xFFFBEED7),
    redSurface: Color(0xFFFCE9E9),
    redBorder: Color(0xFFF0D2D2),
    accentSurface: Color(0xFFFDF3E9),
    accentSurfaceHover: Color(0xFFFBEAD8),
    inverseSurface: Color(0xFF0D2137),
    onInverseSurface: Color(0xFFFFFFFF),
    elevated: Color(0xFFFFFFFF),
    toastBg: Color(0xFF0D2137),
    onToast: Color(0xFFFFFFFF),
    promoA: Color(0xFFE7EEF6),
    promoATile: Color(0xFFCFDDEC),
    promoB: Color(0xFFF7EFE2),
    promoBTile: Color(0xFFEEE3D2),
  );

  /// Dark counterpart. Surfaces are navy-tinted rather than neutral grey so the
  /// app still reads as the same brand, and the status tints are darkened
  /// versions of their light selves rather than the same pale washes.
  static const dark = AppPalette(
    page: Color(0xFF0F1620),
    surface: Color(0xFF18202B),
    field: Color(0xFF1E2733),
    chipBg: Color(0xFF232D3A),
    searchBg: Color(0xFF1E2733),
    infoBg: Color(0xFF1B2430),
    border: Color(0xFF2C3846),
    cardBorder: Color(0xFF2A3442),
    divider: Color(0xFF232D3A),
    navy: Color(0xFFE8EDF3),
    muted: Color(0xFF9AA6B5),
    mutedLight: Color(0xFF7C8899),
    labelIdle: Color(0xFF8894A6),
    infoText: Color(0xFFAAB6C4),
    silver: Color(0xFF8894A6),
    brandNavy: Color(0xFFE8EDF3),
    grayDot: Color(0xFF4A5768),
    greenSurface: Color(0xFF16301F),
    amberSurface: Color(0xFF3A2C12),
    redSurface: Color(0xFF3A1B1B),
    redBorder: Color(0xFF5A2A2A),
    accentSurface: Color(0xFF33240F),
    accentSurfaceHover: Color(0xFF3F2C13),
    inverseSurface: Color(0xFFE8EDF3),
    onInverseSurface: Color(0xFF0F1620),
    elevated: Color(0xFF33404F),
    toastBg: Color(0xFF2E3A49),
    onToast: Color(0xFFE8EDF3),
    promoA: Color(0xFF1C2A38),
    promoATile: Color(0xFF26374A),
    promoB: Color(0xFF322A1C),
    promoBTile: Color(0xFF463A26),
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
      promoA: c(promoA, other.promoA),
      promoATile: c(promoATile, other.promoATile),
      promoB: c(promoB, other.promoB),
      promoBTile: c(promoBTile, other.promoBTile),
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
      seedColor: AppColors.accent,
      brightness: brightness,
      primary: AppColors.accent,
      secondary: AppColors.accent,
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
        (states) => states.contains(WidgetState.selected) ? Colors.white : p.surface,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.accent : p.chipBg,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.accent : p.border,
      ),
      // The default outline thickens on the unselected track; the design's
      // switches are flat.
      trackOutlineWidth: const WidgetStatePropertyAll(1.5),
    ),
  );
}
