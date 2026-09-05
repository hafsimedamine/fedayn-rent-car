// The "do it later" path out of document verification.
//
// Skipping is allowed, but it has to be honest about the cost: without both
// documents the account cannot rent anything, so the sheet says so plainly
// rather than burying it.

import 'package:flutter/material.dart';

import '../theme.dart';
import 'common.dart';

/// Returns true if the user confirmed they want to skip.
Future<bool> confirmSkipVerification(BuildContext context) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: sheetContext.p.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: sheetContext.p.amberSurface, shape: BoxShape.circle),
                child: Icon(Icons.lock_outline_rounded, size: 28, color: context.p.amber),
              ),
            ),
            const SizedBox(height: 18),
            Text('Continuer sans vos documents ?', textAlign: TextAlign.center, style: AppText.heading(20)),
            const SizedBox(height: 10),
            Text(
              'Vous pourrez parcourir la flotte, mais tant que votre CIN et votre '
              'permis de conduire ne sont pas envoyés vous ne pourrez pas :',
              textAlign: TextAlign.center,
              style: AppText.body(13.5, color: sheetContext.p.muted, height: 1.55),
            ),
            const SizedBox(height: 14),
            const _Locked('Réserver une voiture'),
            const _Locked('Finaliser un paiement'),
            const _Locked('Récupérer un véhicule en agence'),
            const SizedBox(height: 18),
            const InfoBanner('Vous pourrez les envoyer à tout moment depuis Compte › Mes documents.'),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Envoyer mes documents',
              onPressed: () => Navigator.of(sheetContext).pop(false),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Passer pour l\'instant',
              height: 54,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

class _Locked extends StatelessWidget {
  const _Locked(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(Icons.block_rounded, size: 16, color: context.p.red),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppText.body(13, color: context.p.infoText))),
          ],
        ),
      );
}

/// Persistent reminder shown at the top of the app while documents are
/// outstanding. Tapping it resumes verification.
class VerificationReminder extends StatelessWidget {
  const VerificationReminder({super.key, required this.missing, required this.onResume});

  final String missing;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) => Material(
        color: context.p.amberSurface,
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: InkWell(
          onTap: onResume,
          borderRadius: BorderRadius.circular(AppRadius.field),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 19, color: context.p.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Location bloquée', style: AppText.body(13, weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        'Envoyez $missing pour pouvoir réserver.',
                        style: AppText.body(11.5, color: context.p.infoText, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: context.p.amber),
              ],
            ),
          ),
        ),
      );
}
