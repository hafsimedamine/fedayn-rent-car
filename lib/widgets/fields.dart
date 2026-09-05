// Floating-label text field + validators, ported from the prototype's
// `field(id, kind)` helper and `static V` validator map.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/password_policy.dart';
import '../theme.dart';

typedef Validator = String? Function(String value);

class V {
  static String? name(String v) =>
      v.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length >= 2 ? null : 'Saisissez votre nom complet';

  static String? email(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(v) ? null : 'Saisissez une adresse e-mail valide';

  /// Numéro marocain : 10 chiffres commençant par 06 ou 07.
  ///
  /// Les espaces, tirets et points de la saisie sont ignorés — « 06 12 34 56 78 »
  /// et « 0612-345678 » sont le même numéro. Un préfixe international +212 est
  /// accepté et ramené à la forme nationale, parce que c'est ce que produit le
  /// carnet d'adresses du téléphone.
  static String? phone(String v) {
    final digits = normalisePhone(v);
    if (digits.isEmpty) return 'Saisissez votre numéro de téléphone';
    if (!RegExp(r'^\d+$').hasMatch(digits)) return 'Le numéro ne doit contenir que des chiffres';
    if (digits.length != 10) {
      return 'Le numéro doit contenir 10 chiffres (${digits.length} saisi${digits.length > 1 ? 's' : ''})';
    }
    if (!digits.startsWith('06') && !digits.startsWith('07')) {
      return 'Le numéro doit commencer par 06 ou 07';
    }
    return null;
  }

  /// Ramène une saisie à ses chiffres en forme nationale.
  /// « +212 6 12 34 56 78 » et « 0612345678 » donnent tous deux « 0612345678 ».
  static String normalisePhone(String v) {
    var s = v.trim().replaceAll(RegExp(r'[\s.\-()]'), '');
    if (s.startsWith('+212')) {
      s = s.substring(4);
    } else if (s.startsWith('00212')) {
      s = s.substring(5);
    } else if (s.startsWith('212') && s.length > 10) {
      s = s.substring(3);
    }
    // Sous forme internationale le 0 initial saute : +212 612... vaut 0612...
    if (s.length == 9 && (s.startsWith('6') || s.startsWith('7'))) s = '0$s';
    return s;
  }

  /// Délègue à [PasswordPolicy] pour que la règle et le générateur ne
  /// puissent pas diverger.
  static String? pw(String v) => PasswordPolicy.validate(v);

  static String? req(String v) => v.isNotEmpty ? null : 'Saisissez votre mot de passe';

  static String? any(String v) => v.trim().isNotEmpty ? null : 'Requis';

  static String? req2(String v) => v.trim().isNotEmpty ? null : 'Ce champ est requis';

  static String? none(String v) => null;
}

/// 58px-tall filled field whose label floats to the top on focus/content.
/// Errors only surface once the field has been touched and is unfocused —
/// matching the prototype so a pristine form never shows red.
class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.validator = V.none,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.trailing,
    this.autoFilled = false,
    this.compactBadge = false,
    this.forceShowError = false,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final Validator validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  /// Widget pinned to the right inside the field (e.g. a show/hide toggle).
  final Widget? trailing;

  /// Shows the green "Auto-rempli" pill used by the scan auto-fill states.
  final bool autoFilled;

  /// Narrow variant of that pill for the half-width date fields.
  final bool compactBadge;

  /// Surface the error even if untouched — used when a submit is attempted.
  final bool forceShowError;

  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  final _focus = FocusNode();
  bool _touched = false;

  /// The error currently on screen, or null. Cached rather than recomputed in
  /// build so a keystroke that does not change it costs no rebuild at all —
  /// which is every keystroke while the field is focused, since errors only
  /// surface once it is touched and blurred.
  String? _shownError;

  @override
  void initState() {
    super.initState();
    _shownError = _visibleError();
    _focus.addListener(_onFocus);
    widget.controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(covariant AppField old) {
    super.didUpdateWidget(old);
    if (!identical(old.controller, widget.controller)) {
      old.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
    }
    // forceShowError flips when a submit is attempted.
    _shownError = _visibleError();
  }

  /// Focus drives the border colour as well as the error, so this always
  /// rebuilds — but it fires twice per field, not once per character.
  void _onFocus() {
    if (!_focus.hasFocus) _touched = true;
    setState(() => _shownError = _visibleError());
  }

  void _onText() {
    final next = _visibleError();
    if (next != _shownError) setState(() => _shownError = next);
  }

  String? _visibleError() {
    final err = widget.validator(widget.controller.text);
    if (err == null) return null;
    return (_touched && !_focus.hasFocus) || widget.forceShowError ? err : null;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final err = _shownError;
    final showErr = err != null;

    final borderColor = showErr
        ? context.p.red
        : focused
            ? context.p.navy
            : context.p.border;

    // The border and fill are painted by this Container, and the field itself
    // runs borderless. InputDecorator owns the label that way, so it lays the
    // floated label and the input out against each other instead of the two
    // colliding — which is what happened while the label was a Stack overlay.
    final suffix = widget.trailing ??
        (widget.autoFilled ? _AutoBadge(compact: widget.compactBadge) : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: context.p.field,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            obscureText: widget.obscure,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            style: AppText.body(widget.compactBadge ? 14 : 15, weight: FontWeight.w500),
            cursorColor: context.p.navy,
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: AppText.body(15, weight: FontWeight.w500, color: context.p.mutedLight),
              floatingLabelStyle: AppText.body(
                11,
                weight: FontWeight.w600,
                color: context.p.labelIdle,
                letterSpacing: 11 * 0.03,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              // Measured, not guessed. InputDecorator centres the
              // label+gap+input block between these paddings, so with a
              // floating label the *typed text* ends up low: at (12, 8) it sat
              // 28.8px below the top border and 9.5px above the bottom one,
              // nearly touching it, and ~10px lower than the placeholder it
              // replaced. Bottom padding is what lifts the block; (6, 16)
              // leaves the label 7.5px clear of the border and puts the text
              // within 2.6px of centre. field_test.dart holds it there.
              contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 16),
              suffixIcon: suffix == null
                  ? null
                  : Padding(padding: const EdgeInsets.only(right: 6), child: suffix),
              suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
            ),
          ),
        ),
        if (showErr)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
            child: Text(err, style: AppText.body(12, weight: FontWeight.w500, color: context.p.red)),
          ),
      ],
    );
  }
}

class _AutoBadge extends StatelessWidget {
  const _AutoBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: compact ? const EdgeInsets.fromLTRB(6, 3, 6, 3) : const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(color: context.p.greenSurface, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(
          compact ? 'Auto' : 'Auto-rempli',
          style: AppText.body(compact ? 9 : 10, weight: FontWeight.w600, color: context.p.green),
        ),
      );
}

/// The select-style dropdown used for licence country/category, times and locations.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T)? itemLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: context.p.field,
                borderRadius: BorderRadius.circular(AppRadius.field),
                border: Border.all(color: context.p.border, width: 1.5),
              ),
              padding: const EdgeInsets.fromLTRB(16, 22, 12, 6),
              alignment: Alignment.bottomLeft,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isDense: true,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: context.p.mutedLight),
                  style: AppText.body(14, weight: FontWeight.w500),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  items: [
                    for (final it in items)
                      DropdownMenuItem(value: it, child: Text(itemLabel?.call(it) ?? '$it')),
                  ],
                  onChanged: (v) => v == null ? null : onChanged(v),
                ),
              ),
            ),
          ),
          Positioned(
            left: 17,
            top: 9,
            child: Text(
              label,
              style: AppText.body(11, weight: FontWeight.w600, color: context.p.labelIdle, letterSpacing: 11 * 0.03),
            ),
          ),
        ],
      ),
    );
  }
}
