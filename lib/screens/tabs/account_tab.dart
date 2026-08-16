import 'package:flutter/material.dart';

import '../../data/fleet.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_picker.dart';
import '../account/contact_us.dart';
import '../account/my_documents.dart';
import '../account/notification_settings.dart';
import '../account/payment_methods.dart';
import '../account/personal_info.dart';
import '../login.dart';
import '../main_shell.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
        children: [
          Text('Mon compte', style: AppText.heading(22)),
          const SizedBox(height: 18),
          _ProfileCard(state: app.verifyState),
          const SizedBox(height: 14),
          _VerificationCard(state: app.verifyState),
          const SizedBox(height: 22),
          const SectionLabel('COMPTE'),
          const SizedBox(height: 10),
          _MenuGroup(rows: [
            _MenuRow(
              icon: Icons.person_outline_rounded,
              label: 'Informations personnelles',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PersonalInfoScreen())),
            ),
            _MenuRow(
              icon: Icons.badge_outlined,
              label: 'Mes documents',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyDocumentsScreen())),
            ),
            _MenuRow(
              icon: Icons.credit_card_rounded,
              label: 'Moyens de paiement',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
            ),
          ]),
          const SizedBox(height: 20),
          const SectionLabel('ACTIVITÉ'),
          const SizedBox(height: 10),
          _MenuGroup(rows: [
            _MenuRow(
              icon: Icons.receipt_long_outlined,
              label: 'Historique des réservations',
              onTap: () => MainShell.of(context).goToTab(1),
            ),
            _MenuRow(icon: Icons.star_border_rounded, label: 'Mes avis', onTap: () => showAppToast(context, 'Mes avis')),
            _MenuRow(
              icon: Icons.favorite_border_rounded,
              label: 'Voitures enregistrées',
              onTap: () => MainShell.of(context).goToTab(2),
            ),
          ]),
          const SizedBox(height: 20),
          const SectionLabel('PRÉFÉRENCES'),
          const SizedBox(height: 10),
          _MenuGroup(rows: [
            _MenuRow(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              ),
            ),
            const _MenuRow(icon: Icons.dark_mode_outlined, label: 'Mode sombre', trailing: _DarkModeSwitch()),
          ]),
          const SizedBox(height: 20),
          const SectionLabel('ASSISTANCE'),
          const SizedBox(height: 10),
          _MenuGroup(rows: [
            _MenuRow(icon: Icons.help_outline_rounded, label: 'Aide et FAQ', onTap: () => showAppToast(context, 'Aide et FAQ')),
            _MenuRow(
              icon: Icons.mail_outline_rounded,
              label: 'Nous contacter',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              ),
            ),
            _MenuRow(
              icon: Icons.shield_outlined,
              label: 'Conditions et confidentialité',
              onTap: () => showAppToast(context, 'Conditions et confidentialité'),
            ),
            _MenuRow(icon: Icons.info_outline_rounded, label: 'À propos', onTap: () => showAppToast(context, 'À propos')),
          ]),
          const SizedBox(height: 20),
          SecondaryButton(
            label: 'Se déconnecter',
            danger: true,
            height: 52,
            onPressed: () => _confirmLogOut(context),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text("Fedayn's Rent Car · v$kAppVersion",
                style: AppText.body(11, weight: FontWeight.w500, color: context.p.grayDot)),
          ),
        ],
      ),
    );
  }
}

/// Confirms, then clears the session and returns to Login with the whole
/// navigation stack removed, so Back cannot re-enter the signed-in app.
Future<void> _confirmLogOut(BuildContext context) async {
  final app = AppScope.read(context);
  final navigator = Navigator.of(context);

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
            const SizedBox(height: 18),
            Text('Se déconnecter ?', style: AppText.heading(20)),
            const SizedBox(height: 8),
            Text('Vous devrez saisir vos identifiants pour revenir.',
                style: AppText.body(13.5, color: sheetContext.p.muted, height: 1.55)),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Se déconnecter',
              background: AppColors.red,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
            const SizedBox(height: 10),
            SecondaryButton(label: 'Annuler', height: 54, onPressed: () => Navigator.of(sheetContext).pop(false)),
          ],
        ),
      ),
    ),
  );

  if (confirmed != true) return;
  app.logOut();
  navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
}

/// Badge colours and copy for each verification state, shared by the profile
/// header, the verification card and Mes documents.
///
/// [missingLabel] differs by context: the account header reads "Non vérifié",
/// while a single document row reads "À fournir".
({String label, Color bg, Color fg}) verifyBadge(
  BuildContext context,
  VerifyState s, {
  String missingLabel = 'Non vérifié',
}) =>
    switch (s) {
      VerifyState.verified => (label: 'Vérifié', bg: context.p.greenSurface, fg: AppColors.green),
      VerifyState.pending => (label: 'En attente', bg: context.p.amberSurface, fg: AppColors.amber),
      VerifyState.rejected => (label: 'Action requise', bg: context.p.redSurface, fg: AppColors.red),
      VerifyState.missing => (label: missingLabel, bg: context.p.amberSurface, fg: AppColors.amber),
    };

/// The icon that goes with a status in a document row.
IconData verifyIcon(VerifyState s) => switch (s) {
      VerifyState.verified => Icons.check_circle_rounded,
      VerifyState.pending => Icons.schedule_rounded,
      VerifyState.rejected => Icons.error_outline_rounded,
      VerifyState.missing => Icons.upload_file_rounded,
    };

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.state});

  final VerifyState state;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final badge = verifyBadge(context, state);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.p.cardBorder),
        boxShadow: [BoxShadow(color: context.p.navy.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const _ProfileAvatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(app.piName, style: AppText.heading(17)),
                    StatusPill(label: badge.label, background: badge.bg, foreground: badge.fg, fontSize: 10),
                  ],
                ),
                const SizedBox(height: 3),
                Text(app.piEmail, style: AppText.body(12.5, color: context.p.muted)),
                const SizedBox(height: 1),
                Text(app.piPhone, style: AppText.body(12.5, color: context.p.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The avatar, with a working camera badge.
///
/// The badge used to be decoration — an icon in a circle with nothing behind
/// it. Tapping anywhere on the avatar now offers camera or gallery and keeps
/// what comes back.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  Future<void> _change(BuildContext context) async {
    final app = AppScope.read(context);
    final source = await choosePhotoSource(context);
    if (source == null || !context.mounted) return;
    final picked = await pickPhoto(context, source);
    if (picked == null || !context.mounted) return;
    app.setProfilePhoto(picked);
    showAppToast(context, 'Photo de profil mise à jour');
  }

  @override
  Widget build(BuildContext context) {
    final photo = AppScope.of(context).profilePhoto;
    final image = photoImage(photo);

    return InkWell(
      onTap: () => _change(context),
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: context.p.chipBg, shape: BoxShape.circle),
              child: image ?? Icon(Icons.person_outline_rounded, size: 30, color: context.p.mutedLight),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: context.p.inverseSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.p.surface, width: 2),
                ),
                child: Icon(Icons.photo_camera_rounded, size: 10, color: context.p.onInverseSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.state});

  final VerifyState state;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final verified = state == VerifyState.verified;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: verified ? context.p.greenSurface.withValues(alpha: 0.45) : context.p.field,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: verified ? context.p.greenSurface : context.p.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vérification d'identité", style: AppText.body(14, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            switch (state) {
              VerifyState.verified => 'Votre CIN et votre permis sont approuvés.',
              VerifyState.pending => 'Nous examinons vos documents (généralement sous 24 h).',
              VerifyState.rejected => 'Document illisible — merci de réimporter votre CIN.',
              VerifyState.missing => 'Envoyez ${app.missingDocumentsLabel} pour pouvoir réserver.',
            },
            style: AppText.body(12.5, color: context.p.muted, height: 1.5),
          ),
          const SizedBox(height: 14),
          _DocStatusRow(label: "Carte d'identité (CIN)", state: app.cinStatus),
          const SizedBox(height: 8),
          _DocStatusRow(label: 'Permis de conduire', state: app.licenseStatus),
          if (!verified) ...[
            const SizedBox(height: 14),
            SecondaryButton(
              label: state == VerifyState.missing ? 'Envoyer mes documents' : 'Gérer mes documents',
              height: 46,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyDocumentsScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocStatusRow extends StatelessWidget {
  const _DocStatusRow({required this.label, required this.state});

  final String label;
  final VerifyState state;

  @override
  Widget build(BuildContext context) {
    final badge = verifyBadge(context, state, missingLabel: 'À fournir');
    return Row(
      children: [
        Icon(verifyIcon(state), size: 16, color: badge.fg),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppText.body(13, weight: FontWeight.w500))),
        StatusPill(label: badge.label, background: badge.bg, foreground: badge.fg, fontSize: 10),
      ],
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1) Divider(height: 1, color: context.p.divider, indent: 52),
            ],
          ],
        ),
      );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.onTap, this.trailing});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: context.p.muted),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: AppText.body(14, weight: FontWeight.w500))),
              trailing ?? Icon(Icons.chevron_right_rounded, size: 20, color: context.p.mutedLight),
            ],
          ),
        ),
      );
}

class _DarkModeSwitch extends StatelessWidget {
  const _DarkModeSwitch();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Switch(value: app.isDarkMode, onChanged: app.setDarkMode);
  }
}
