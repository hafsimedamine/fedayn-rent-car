// Booking step 2 — review, extras, additional-driver sub-form and price breakdown.

import 'package:flutter/material.dart';

import '../../data/fleet.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/car_card.dart';
import '../../widgets/common.dart';
import '../../widgets/fields.dart';
import 'book_payment.dart';

class BookReviewScreen extends StatefulWidget {
  const BookReviewScreen({super.key});

  @override
  State<BookReviewScreen> createState() => _BookReviewScreenState();
}

class _BookReviewScreenState extends State<BookReviewScreen> {
  final _adName = TextEditingController();
  final _adCin = TextEditingController();
  final _adLicense = TextEditingController();
  final _adExpiry = TextEditingController();
  final _promo = TextEditingController();

  /// Set once the user tries to continue with an incomplete sub-form, so the
  /// inline "Ce champ est requis" errors appear.
  bool _showAdErrors = false;

  @override
  void dispose() {
    for (final c in [_adName, _adCin, _adLicense, _adExpiry, _promo]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncDraft(BookingDraft d) {
    d.adName = _adName.text;
    d.adCin = _adCin.text;
    d.adLicense = _adLicense.text;
    d.adExpiry = _adExpiry.text;
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
            TopBar(title: 'Récapitulatif', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                children: [
                  Text('Vérifiez votre réservation', style: AppText.heading(22)),
                  const SizedBox(height: 16),
                  _CarRow(draft: d),
                  const SizedBox(height: 20),
                  const SectionLabel('DÉTAILS DU TRAJET'),
                  const SizedBox(height: 10),
                  _TripCard(draft: d),
                  const SizedBox(height: 20),
                  const SectionLabel('INCLUS'),
                  const SizedBox(height: 10),
                  for (final item in kIncluded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 17, color: AppColors.green),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item, style: AppText.body(13, color: context.p.infoText))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  const SectionLabel('OPTIONS'),
                  const SizedBox(height: 10),
                  AppCheckbox(
                    value: d.extraDriver,
                    onChanged: (v) => setState(() {
                      d.extraDriver = v;
                      if (!v) _showAdErrors = false;
                    }),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Conducteur supplémentaire', style: AppText.body(13.5, weight: FontWeight.w500)),
                        ),
                        Text('Gratuit', style: AppText.body(13, weight: FontWeight.w600, color: AppColors.green)),
                      ],
                    ),
                  ),
                  // Required sub-form, revealed only while the option is checked.
                  if (d.extraDriver) _additionalDriverForm(d),
                  const SizedBox(height: 10),
                  AppCheckbox(
                    value: d.extraChildSeat,
                    onChanged: (v) => setState(() => d.extraChildSeat = v),
                    child: Row(
                      children: [
                        Expanded(child: Text('Siège enfant', style: AppText.body(13.5, weight: FontWeight.w500))),
                        Text('+40 MAD', style: AppText.body(13, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('CODE PROMO'),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: AppField(label: 'Code promo', controller: _promo)),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            final ok = _promo.text.trim().toUpperCase() == 'WEEK20';
                            setState(() => d.promoApplied = ok);
                            showAppToast(context, ok ? 'Code appliqué : −20 %' : 'Code promo invalide');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.p.inverseSurface,
                            foregroundColor: context.p.onInverseSurface,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
                          ),
                          child: Text('Appliquer',
                              style: AppText.body(14, weight: FontWeight.w600, color: context.p.onInverseSurface)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _PriceBreakdown(draft: d),
                ],
              ),
            ),
            StickyBar(
              child: PrimaryButton(
                label: 'Procéder au paiement',
                enabled: d.canProceed,
                onPressed: () {
                  _syncDraft(d);
                  if (!d.canProceed) {
                    setState(() => _showAdErrors = true);
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookPaymentScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _additionalDriverForm(BookingDraft d) => Container(
        margin: const EdgeInsets.only(top: 12, left: 33),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.p.field,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: context.p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Informations du conducteur', style: AppText.body(12.5, weight: FontWeight.w600)),
                const SizedBox(width: 8),
                StatusPill(
                  label: 'Requis',
                  background: context.p.redSurface,
                  foreground: AppColors.red,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppField(
              label: 'Nom complet',
              controller: _adName,
              validator: V.req2,
              forceShowError: _showAdErrors,
              onChanged: (_) => setState(() => _syncDraft(d)),
            ),
            const SizedBox(height: 10),
            AppField(
              label: 'Numéro de CIN',
              controller: _adCin,
              validator: V.req2,
              forceShowError: _showAdErrors,
              onChanged: (_) => setState(() => _syncDraft(d)),
            ),
            const SizedBox(height: 10),
            AppField(
              label: 'Numéro de permis',
              controller: _adLicense,
              validator: V.req2,
              forceShowError: _showAdErrors,
              onChanged: (_) => setState(() => _syncDraft(d)),
            ),
            const SizedBox(height: 10),
            AppField(
              label: "Date d'expiration du permis",
              controller: _adExpiry,
              validator: V.req2,
              forceShowError: _showAdErrors,
              onChanged: (_) => setState(() => _syncDraft(d)),
            ),
          ],
        ),
      );
}

class _CarRow extends StatelessWidget {
  const _CarRow({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.cardBorder),
        ),
        child: Row(
          children: [
            CarThumb(car: draft.car, width: 84, height: 62),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(draft.car.name, style: AppText.body(14.5, weight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('${catFr(draft.car.cat)} • ${transFr(draft.car.trans)}',
                      style: AppText.body(11.5, color: context.p.mutedLight)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.cardBorder),
        ),
        child: Column(
          children: [
            _row(context, 'Prise en charge', '${draft.pickDay} juil. · ${draft.pickTime}', draft.pickLoc),
            Divider(height: 1, color: context.p.divider),
            _row(context, 'Retour', '${draft.retDay} juil. · ${draft.retTime}', draft.effectiveRetLoc),
            Divider(height: 1, color: context.p.divider),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Durée', style: AppText.body(12.5, weight: FontWeight.w500, color: context.p.muted)),
                  Text('${draft.days} jours', style: AppText.body(12.5, weight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _row(BuildContext context, String label, String when, String where) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label, style: AppText.body(12.5, weight: FontWeight.w500, color: context.p.muted)),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(when, style: AppText.body(12.5, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(where, textAlign: TextAlign.end, style: AppText.body(11.5, color: context.p.mutedLight)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.p.field,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.border),
        ),
        child: Column(
          children: [
            _line(context, '${draft.days} jours × ${fmtMad(draft.car.price)} MAD', '${fmtMad(draft.base)} MAD'),
            if (draft.extras > 0) ...[
              const SizedBox(height: 8),
              _line(context, 'Siège enfant', '+${fmtMad(draft.extras)} MAD'),
            ],
            const SizedBox(height: 8),
            _line(context, 'Frais de service', '+${fmtMad(BookingDraft.serviceFee)} MAD'),
            if (draft.discount > 0) ...[
              const SizedBox(height: 8),
              _line(context, 'Code promo WEEK20', '−${fmtMad(draft.discount)} MAD', highlight: AppColors.green),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: context.p.border),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Total', style: AppText.body(14, weight: FontWeight.w600)),
                Text('${fmtMad(draft.total)} MAD',
                    style: AppText.heading(22, color: AppColors.accent, weight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );

  Widget _line(BuildContext context, String label, String value, {Color? highlight}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body(12.5, color: context.p.muted)),
          Text(value, style: AppText.body(12.5, weight: FontWeight.w600, color: highlight ?? context.p.navy)),
        ],
      );
}
