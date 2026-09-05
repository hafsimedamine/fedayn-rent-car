// Shared chrome: brand logo, buttons, headers, badges, cards and banners.

import 'package:flutter/material.dart';

import '../theme.dart';

/// The brand lockup: real logo mark + wordmark + tagline.
/// On dark surfaces the navy/silver mark sits on a white card so it stays legible.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 40, this.dark = false});

  final double size;

  /// Set when the logo sits on a dark surface inside a *light* theme — the
  /// welcome hero. A dark theme is detected automatically.
  final bool dark;

  static const _aspect = 400 / 206; // intrinsic ratio of logo_fedayns.png

  @override
  Widget build(BuildContext context) {
    // The mark is navy and silver, so it needs a light plate on any dark
    // ground — the hero in light theme, and every screen in dark theme.
    final onDark = dark || Theme.of(context).brightness == Brightness.dark;

    final iconH = size * 0.9;
    final iconW = iconH * _aspect;
    // Decode at ~2x the drawn size instead of scaling the full 488px bitmap
    // down at paint time, which is what made the mark look pixelated in the
    // home header.
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final icon = Image.asset(
      'assets/images/logo_fedayns.png',
      width: iconW,
      height: iconH,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      // Exactly one source pixel per device pixel. This used to ask for twice
      // that, which decoded four times the bitmap for no visible gain — and
      // now that the asset is 400px wide it would have to upscale to deliver
      // it. The asset is sized so this never exceeds its intrinsic width.
      cacheWidth: (iconW * dpr).round(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onDark)
          Container(
            padding: EdgeInsets.all(size * 0.22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.28 : 0.18),
                  blurRadius: dark ? 24 : 12,
                  offset: Offset(0, dark ? 10 : 4),
                ),
              ],
            ),
            child: icon,
          )
        else
          icon,
        SizedBox(height: size * 0.12),
        Text(
          "Fedayn's Rent Car",
          style: AppText.heading(size * 0.34,
              color: onDark ? Colors.white : context.p.brandNavy, weight: FontWeight.w700, height: 1),
        ),
        SizedBox(height: size * 0.06),
        Text(
          'LOCATION AUTOMOBILE & SERVICE PREMIUM',
          textAlign: TextAlign.center,
          style: AppText.body(size * 0.13,
              weight: FontWeight.w600,
              color: onDark ? Colors.white.withValues(alpha: 0.6) : context.p.silver,
              letterSpacing: size * 0.13 * 0.18),
        ),
      ],
    );
  }
}

/// Full-width 54px CTA. Disabled state greys out but stays laid out identically.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    // Nullables, résolues au rendu : une valeur par défaut doit être const, et
    // l'accent dépend désormais du thème.
    this.background,
    this.foreground,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? background;
  final Color? foreground;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fond = background ?? context.p.accent;
    final texte = foreground ?? context.p.onAccent;
    final bg = enabled ? fond : context.p.grayDot;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.field),
          boxShadow: enabled
              ? [BoxShadow(color: fond.withValues(alpha: 0.22), blurRadius: 20, offset: const Offset(0, 8))]
              : null,
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            disabledBackgroundColor: context.p.grayDot,
            foregroundColor: texte,
            disabledForegroundColor: context.p.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
          ),
          child: Text(label, style: AppText.body(16, weight: FontWeight.w600, color: texte)),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.dark = false,
    this.height = 52,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  final double height;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? context.p.red : (dark ? Colors.white : context.p.navy);
    final border = danger ? context.p.redBorder : (dark ? Colors.white.withValues(alpha: 0.3) : context.p.border);
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          backgroundColor: dark ? Colors.white.withValues(alpha: 0.06) : context.p.surface,
          side: BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
        ),
        child: Text(label, style: AppText.body(15, weight: FontWeight.w600, color: fg)),
      ),
    );
  }
}

/// 38px rounded back chevron used on every pushed screen.
class BackChevron extends StatelessWidget {
  const BackChevron({super.key, this.onTap, this.dark = false});

  final VoidCallback? onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.12) : context.p.chipBg,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.chevron_left_rounded, size: 24, color: dark ? Colors.white : context.p.navy),
      ),
    );
  }
}

/// "ÉTAPE n SUR 3" + the three progress bars.
/// "Passer" in the step header.
///
/// The verification steps also offer skipping at the bottom of the form, but
/// that is below the fold on a phone — behind the capture cards, four fields
/// and an info banner — so someone looking for a way past the step never saw
/// it. This one is visible the moment the screen opens.
class SkipLink extends StatelessWidget {
  const SkipLink({super.key, required this.onTap, this.label = 'Passer'});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: AppText.body(13.5, weight: FontWeight.w600, color: context.p.muted),
          ),
        ),
      );
}

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.step});

  final int step; // 1-based

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('ÉTAPE $step SUR 3', style: AppText.overline()),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 3; i++) ...[
              Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: i < step
                      ? context.p.navy // completed
                      : i == step
                          ? context.p.accent // current
                          : context.p.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (i < 3) const SizedBox(width: 4),
            ],
          ],
        ),
      ],
    );
  }
}

/// Small all-caps group heading, e.g. "DÉTAILS DE LA PIÈCE".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppText.overline());
}

/// Green-dot + microcopy trust signal.
class TrustNote extends StatelessWidget {
  const TrustNote(this.text, {super.key, this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: context.p.green, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Flexible(child: Text(text, style: AppText.body(12, weight: FontWeight.w500, color: context.p.mutedLight))),
        ],
      );
}

/// Light info banner with a leading dot.
class InfoBanner extends StatelessWidget {
  const InfoBanner(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(color: context.p.infoBg, borderRadius: BorderRadius.circular(AppRadius.small)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: context.p.green, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppText.body(12, color: context.p.infoText, height: 1.5))),
          ],
        ),
      );
}

/// Square checkbox with the design's 22px rounded box and white tick.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.value, required this.onChanged, required this.child});

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 1),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? context.p.accent : Colors.transparent,
                border: Border.all(color: value ? context.p.accent : context.p.border, width: 1.5),
                borderRadius: BorderRadius.circular(7),
              ),
              child: value ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 11),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Coloured status pill (Confirmée / En attente / Vérifié …).
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.background, required this.foreground, this.fontSize = 11});

  final String label;
  final Color? background;
  final Color? foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: fontSize <= 10 ? 8 : 10, vertical: fontSize <= 10 ? 3 : 5),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(label, style: AppText.body(fontSize, weight: FontWeight.w600, color: foreground)),
      );
}

/// Availability dot + label used on car cards.
class AvailabilityDot extends StatelessWidget {
  const AvailabilityDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(11.5, weight: FontWeight.w500, color: context.p.muted)),
          ),
        ],
      );
}

/// Sticky bottom action bar with the design's hairline top border.
class StickyBar extends StatelessWidget {
  const StickyBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        decoration: BoxDecoration(
          color: context.p.page,
          border: Border(top: BorderSide(color: context.p.divider)),
        ),
        child: SafeArea(top: false, child: child),
      );
}

/// Screen top bar: back chevron + centred title.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.onBack, this.trailing});

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: Row(
          children: [
            BackChevron(onTap: onBack),
            Expanded(
              child: Text(title, textAlign: TextAlign.center, style: AppText.heading(17)),
            ),
            SizedBox(width: 38, child: trailing),
          ],
        ),
      );
}

/// App-wide messenger, so a toast can be dismissed from outside any one screen
/// (see [ToastRouteObserver]).
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Clears any visible toast as soon as the user leaves the screen that raised
/// it. Snackbars outlive route changes by default, so without this a toast
/// follows the user onto the next page.
class ToastRouteObserver extends NavigatorObserver {
  void _clear() => scaffoldMessengerKey.currentState?.clearSnackBars();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _clear();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _clear();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _clear();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _clear();
}

/// Dismisses any visible toast — used when switching bottom-nav tabs, which is
/// not a route change and so does not reach [ToastRouteObserver].
void dismissAppToasts() => scaffoldMessengerKey.currentState?.clearSnackBars();

/// Toast with an optional Undo action, matching the prototype's bottom pill.
/// Auto-dismisses after 3s, or immediately if the user navigates away.
void showAppToast(BuildContext context, String message, {VoidCallback? onUndo}) {
  final messenger = scaffoldMessengerKey.currentState ?? ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: context.p.toastBg,
      duration: const Duration(seconds: 3),
      // Flutter defaults persist to `action != null`, which would leave every
      // toast carrying an Undo button on screen until the user navigates away.
      persist: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 24),
      content: Text(message,
          style: AppText.body(13, weight: FontWeight.w500, color: context.p.onToast)),
      action: onUndo == null
          ? null
          : SnackBarAction(label: 'Annuler', textColor: context.p.accent, onPressed: onUndo),
    ),
  );
}


/// Inline form-level error, for failures that belong to the submission rather
/// than to one field (bad credentials, email already taken).
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.p.redSurface,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: context.p.redBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 17, color: context.p.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: AppText.body(12.5, weight: FontWeight.w500, color: context.p.red, height: 1.4)),
            ),
          ],
        ),
      );
}
