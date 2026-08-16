// Booking step 5 — confirmation with the reference card and next actions.

import 'package:flutter/material.dart';

import '../../data/fleet.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../main_shell.dart';

class BookConfirmScreen extends StatelessWidget {
  const BookConfirmScreen({super.key});

  static const _ref = 'RC2847';

  @override
  Widget build(BuildContext context) {
    final d = AppScope.of(context).draft;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(26, 40, 26, 24),
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(color: context.p.greenSurface, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, size: 42, color: AppColors.green),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Réservation confirmée !', textAlign: TextAlign.center, style: AppText.heading(26)),
                  const SizedBox(height: 10),
                  Text(
                    'Votre ${d.car.name} est réservée du ${d.pickDay} au ${d.retDay} juillet.',
                    textAlign: TextAlign.center,
                    style: AppText.body(14.5, color: context.p.muted, height: 1.55),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.p.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: context.p.cardBorder),
                      boxShadow: [
                        BoxShadow(color: context.p.navy.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Référence', style: AppText.body(12.5, weight: FontWeight.w500, color: context.p.muted)),
                            Text('#$_ref', style: AppText.body(14, weight: FontWeight.w700)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: context.p.divider),
                        ),
                        _row(context, 'Locataire', kUserName),
                        _row(context, 'Véhicule', d.car.name),
                        _row(context, 'Prise en charge', '${d.pickDay} juil. · ${d.pickTime}'),
                        _row(context, 'Retour', '${d.retDay} juil. · ${d.retTime}'),
                        _row(context, 'Lieu', d.pickLoc),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: context.p.divider),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total payé', style: AppText.body(13, weight: FontWeight.w600)),
                            Text('${fmtMad(d.total)} MAD',
                                style: AppText.heading(20, color: AppColors.accent, weight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const InfoBanner('Le contrat de location a été généré et envoyé par e-mail.'),
                ],
              ),
            ),
            StickyBar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: 'Voir ma location',
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainShell(initialTab: 1)),
                      (_) => false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: "Retour à l'accueil",
                    height: 54,
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                      (_) => false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.body(12.5, weight: FontWeight.w500, color: context.p.muted)),
            Flexible(
              child: Text(value, textAlign: TextAlign.end, style: AppText.body(12.5, weight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
