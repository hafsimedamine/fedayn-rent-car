// Compte › Préférences › Notifications.
//
// Every switch here is stored, so the choice survives a restart. Grouping is
// by what the notification is *about*, with delivery channels pulled out on
// top — turning all three off silences everything, and the screen says so
// rather than leaving the topic switches looking effective.

import 'package:flutter/material.dart';

import '../../data/notification_prefs.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final prefs = app.notifications;

    void update(NotificationPrefs next) => app.setNotificationPrefs(next);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Notifications', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                children: [
                  if (prefs.allChannelsOff) ...[
                    const _SilencedBanner(),
                    const SizedBox(height: 18),
                  ],
                  const SectionLabel('CANAUX'),
                  const SizedBox(height: 10),
                  _Group(rows: [
                    _SwitchRow(
                      icon: Icons.notifications_active_outlined,
                      label: 'Notifications push',
                      subtitle: 'Sur cet appareil',
                      value: prefs.push,
                      onChanged: (v) => update(prefs.copyWith(push: v)),
                    ),
                    _SwitchRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'E-mail',
                      subtitle: app.piEmail,
                      value: prefs.email,
                      onChanged: (v) => update(prefs.copyWith(email: v)),
                    ),
                    _SwitchRow(
                      icon: Icons.sms_outlined,
                      label: 'SMS',
                      subtitle: 'Réservé aux alertes urgentes',
                      value: prefs.sms,
                      onChanged: (v) => update(prefs.copyWith(sms: v)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const SectionLabel('MES RÉSERVATIONS'),
                  const SizedBox(height: 10),
                  _Group(rows: [
                    _SwitchRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'Confirmations et modifications',
                      subtitle: 'Réservation confirmée, annulée ou modifiée',
                      value: prefs.bookingUpdates,
                      onChanged: (v) => update(prefs.copyWith(bookingUpdates: v)),
                    ),
                    _SwitchRow(
                      icon: Icons.event_available_outlined,
                      label: 'Rappel de prise en charge',
                      subtitle: 'La veille et 2 h avant',
                      value: prefs.pickupReminders,
                      onChanged: (v) => update(prefs.copyWith(pickupReminders: v)),
                    ),
                    _SwitchRow(
                      icon: Icons.assignment_return_outlined,
                      label: 'Rappel de retour',
                      subtitle: 'Pour éviter les frais de retard',
                      value: prefs.returnReminders,
                      onChanged: (v) => update(prefs.copyWith(returnReminders: v)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const SectionLabel('VOITURES ENREGISTRÉES'),
                  const SizedBox(height: 10),
                  _Group(rows: [
                    _SwitchRow(
                      icon: Icons.directions_car_outlined,
                      label: 'Voiture à nouveau disponible',
                      subtitle: 'Quand une voiture enregistrée se libère',
                      value: prefs.availabilityAlerts,
                      onChanged: (v) => update(prefs.copyWith(availabilityAlerts: v)),
                    ),
                    _SwitchRow(
                      icon: Icons.trending_down_rounded,
                      label: 'Baisse de prix',
                      subtitle: 'Quand le tarif journalier baisse',
                      value: prefs.priceDrops,
                      onChanged: (v) => update(prefs.copyWith(priceDrops: v)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const SectionLabel('OFFRES ET ACTUALITÉS'),
                  const SizedBox(height: 10),
                  _Group(rows: [
                    _SwitchRow(
                      icon: Icons.local_offer_outlined,
                      label: 'Nouvelles offres',
                      subtitle: 'Promotions et nouveautés de la flotte',
                      value: prefs.newOffers,
                      onChanged: (v) => update(prefs.copyWith(newOffers: v)),
                    ),
                    _SwitchRow(
                      icon: Icons.campaign_outlined,
                      label: 'E-mails promotionnels',
                      subtitle: 'Au maximum un par mois',
                      value: prefs.promoEmails,
                      onChanged: (v) => update(prefs.copyWith(promoEmails: v)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const SectionLabel('TRANQUILLITÉ'),
                  const SizedBox(height: 10),
                  _Group(rows: [
                    _SwitchRow(
                      icon: Icons.bedtime_outlined,
                      label: 'Heures silencieuses',
                      subtitle: 'Rien entre 22 h et 7 h',
                      value: prefs.quietHours,
                      onChanged: (v) => update(prefs.copyWith(quietHours: v)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  const InfoBanner(
                    'Les alertes liées à une réservation en cours vous parviennent toujours, '
                    'même pendant les heures silencieuses.',
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

class _SilencedBanner extends StatelessWidget {
  const _SilencedBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.p.amberSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notifications_off_outlined, size: 19, color: context.p.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tout est coupé', style: AppText.body(13.5, weight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(
                    'Aucun canal actif : nous ne pourrons pas vous prévenir, '
                    'même pour une réservation.',
                    style: AppText.body(12, color: context.p.infoText, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.cardBorder),
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(color: context.p.divider, height: 1, indent: 56),
              rows[i],
            ],
          ],
        ),
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
        // The whole row toggles, not just the 50px switch.
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: context.p.muted),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: AppText.body(14, weight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.body(11.5, color: context.p.mutedLight, height: 1.35)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Plain Switch, not .adaptive: the rest of the app is Material
              // throughout, including the dark-mode switch on the screen that
              // links here, and an iOS-shaped one would not take the accent.
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      );
}
