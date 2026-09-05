// Compte › Assistance › Nous contacter.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/fleet.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Nous contacter', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                children: [
                  Text('Une question ?', style: AppText.heading(20)),
                  const SizedBox(height: 6),
                  Text(
                    'Notre équipe répond du lundi au samedi, de 9 h à 19 h.',
                    style: AppText.body(13.5, color: context.p.muted, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const _ContactCard(
                    icon: Icons.phone_outlined,
                    label: 'Téléphone',
                    value: kSupportPhone,
                    hint: 'Appuyez pour copier le numéro',
                  ),
                  const SizedBox(height: 12),
                  const _ContactCard(
                    icon: Icons.mail_outline_rounded,
                    label: 'E-mail',
                    value: kSupportEmail,
                    hint: "Appuyez pour copier l'adresse",
                  ),
                  const SizedBox(height: 20),
                  const InfoBanner(
                    'Munissez-vous de votre numéro de réservation (par exemple RC2847) '
                    'pour que nous puissions vous répondre plus vite.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tapping copies the value.
///
/// Deliberately not a `tel:` / `mailto:` launch — that needs url_launcher plus
/// `<queries>` entries in the Android manifest, and this build has never been
/// compiled for a device. Copying works everywhere and cannot silently no-op.
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
  });

  final IconData icon;
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) => Material(
        color: context.p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: value));
            if (context.mounted) showAppToast(context, '$label copié');
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: context.p.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: context.p.accentSurface, shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: context.p.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: AppText.body(11.5, weight: FontWeight.w600, color: context.p.mutedLight)),
                      const SizedBox(height: 3),
                      // Long on a 360px screen, so it wraps rather than clipping.
                      Text(value, style: AppText.body(15, weight: FontWeight.w600), softWrap: true),
                      const SizedBox(height: 3),
                      Text(hint, style: AppText.body(11, color: context.p.mutedLight)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.copy_rounded, size: 17, color: context.p.mutedLight),
              ],
            ),
          ),
        ),
      );
}
