// Booking step 3 — payment method + strictly validated card form.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/fleet.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/fields.dart';
import '../../widgets/form_gate.dart';
import 'book_processing.dart';

/// Groups digits in fours: "1234 5678 9012 3456".
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buf = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(capped[i]);
    }
    final text = buf.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class BookPaymentScreen extends StatefulWidget {
  const BookPaymentScreen({super.key});

  @override
  State<BookPaymentScreen> createState() => _BookPaymentScreenState();
}

class _BookPaymentScreenState extends State<BookPaymentScreen> {
  final _number = TextEditingController();
  final _cvv = TextEditingController();
  final _holder = TextEditingController();

  // Default to the current month/year: anything earlier is expired, and the
  // form must not show an error before the user has touched it.
  String _expMonth = DateTime.now().month.toString().padLeft(2, '0');
  String _expYear = kYears.contains('${DateTime.now().year}') ? '${DateTime.now().year}' : kYears.first;
  bool _cardMethod = true;
  bool _saveCard = true;
  bool _expiryTouched = false;

  @override
  void dispose() {
    for (final c in [_number, _cvv, _holder]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _digits => _number.text.replaceAll(RegExp(r'\D'), '');

  String? _numberError(String v) => _digits.length == 16 ? null : 'Entrez un numéro de carte valide (16 chiffres)';
  String? _cvvError(String v) => v.length == 3 ? null : 'Le CVV doit contenir 3 chiffres';
  String? _holderError(String v) =>
      v.trim().isNotEmpty && RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(v) ? null : 'Nom invalide';

  /// Cards expire at the end of their month; anything before "now" is expired.
  bool get _expiryValid {
    final now = DateTime.now();
    final y = int.parse(_expYear);
    final m = int.parse(_expMonth);
    return y > now.year || (y == now.year && m >= now.month);
  }

  bool get _cardValid =>
      _digits.length == 16 && _cvv.text.length == 3 && _holderError(_holder.text) == null && _expiryValid;

  bool get _canPay => !_cardMethod || _cardValid;

  /// Visa starts with 4; Mastercard with 51–55 or 2221–2720 (2 is enough here).
  String? get _brand {
    if (_digits.isEmpty) return null;
    if (_digits.startsWith('4')) return 'VISA';
    if (_digits.startsWith('5') || _digits.startsWith('2')) return 'MC';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = app.draft;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Paiement', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text('Montant total', style: AppText.body(13, color: context.p.muted)),
                        const SizedBox(height: 4),
                        Text('${fmtMad(d.total)} MAD',
                            style: AppText.heading(32, color: context.p.accent, weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel('MOYEN DE PAIEMENT'),
                  const SizedBox(height: 10),
                  _MethodTile(
                    selected: _cardMethod,
                    icon: Icons.credit_card_rounded,
                    title: 'Carte bancaire',
                    subtitle: 'Visa · Mastercard',
                    onTap: () => setState(() => _cardMethod = true),
                  ),
                  const SizedBox(height: 10),
                  _MethodTile(
                    selected: !_cardMethod,
                    icon: Icons.payments_outlined,
                    title: 'Paiement à la prise en charge',
                    subtitle: 'En espèces à l\'agence',
                    onTap: () => setState(() => _cardMethod = false),
                  ),
                  if (_cardMethod) ...[
                    const SizedBox(height: 22),
                    const SectionLabel('DÉTAILS DE LA CARTE'),
                    const SizedBox(height: 12),
                    AppField(
                      label: 'Numéro de carte',
                      controller: _number,
                      validator: _numberError,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_CardNumberFormatter()],
                      // VISA/MC badge: the only other thing that tracks the
                      // number while it is typed, so it listens on its own
                      // instead of the screen rebuilding for it.
                      trailing: AnimatedBuilder(
                        animation: _number,
                        builder: (context, _) => _brand == null
                            ? const SizedBox.shrink()
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.p.field,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: context.p.border),
                                ),
                                child: Text(_brand!, style: AppText.body(10, weight: FontWeight.w700)),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppDropdown<String>(
                            label: 'Mois',
                            value: _expMonth,
                            items: kMonths,
                            onChanged: (v) => setState(() { _expMonth = v; _expiryTouched = true; }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppDropdown<String>(
                            label: 'Année',
                            value: _expYear,
                            items: kYears,
                            onChanged: (v) => setState(() { _expYear = v; _expiryTouched = true; }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppField(
                            label: 'CVV',
                            controller: _cvv,
                            validator: _cvvError,
                            obscure: true,
                            compactBadge: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!_expiryValid && _expiryTouched)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
                        child: Text('Carte expirée',
                            style: AppText.body(12, weight: FontWeight.w500, color: context.p.red)),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.help_outline_rounded, size: 14, color: context.p.mutedLight),
                        const SizedBox(width: 6),
                        Text('Code à 3 chiffres au dos de votre carte',
                            style: AppText.body(11.5, color: context.p.mutedLight)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppField(
                      label: 'Nom du titulaire',
                      controller: _holder,
                      validator: _holderError,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]'))],
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 14),
                    AppCheckbox(
                      value: _saveCard,
                      onChanged: (v) => setState(() => _saveCard = v),
                      child: Text('Enregistrer cette carte', style: AppText.body(13.5, weight: FontWeight.w500)),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 14, color: context.p.green),
                      const SizedBox(width: 7),
                      Text('Paiement sécurisé et crypté',
                          style: AppText.body(12, weight: FontWeight.w500, color: context.p.mutedLight)),
                    ],
                  ),
                ],
              ),
            ),
            StickyBar(
              child: FormGate(
                listenTo: [_number, _cvv, _holder],
                test: () => _canPay,
                builder: (_, enabled) => PrimaryButton(
                  label: _cardMethod ? 'Payer ${fmtMad(d.total)} MAD' : 'Confirmer la réservation',
                  enabled: enabled,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BookProcessingScreen()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? context.p.accentSurface : context.p.surface,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: selected ? context.p.accent : context.p.border, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? context.p.accent : context.p.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppText.body(13.5, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.body(11.5, color: context.p.mutedLight)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? context.p.accent : context.p.border,
              ),
            ],
          ),
        ),
      );
}
