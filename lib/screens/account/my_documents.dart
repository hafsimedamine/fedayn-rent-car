// Compte › Mes documents.
//
// This screen is the one place a user can supply, review or replace their
// documents after the fact — including after skipping verification at signup.
// Its badges are derived from what is actually stored, never from a fixture.

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/capture_cards.dart';
import '../../widgets/common.dart';
import '../tabs/account_tab.dart';

class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Mes documents', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                children: [
                  if (!app.documentsComplete) ...[
                    _MissingNotice(missing: app.missingDocumentsLabel),
                    const SizedBox(height: 18),
                  ],
                  _DocSection(
                    title: "Carte d'identité (CIN)",
                    state: app.cinStatus,
                    photo: app.cinPhoto,
                    onPicked: (photo) => app.markCinUploaded(photo: photo),
                    onRemove: app.clearCin,
                  ),
                  const SizedBox(height: 20),
                  _DocSection(
                    title: 'Permis de conduire',
                    state: app.licenseStatus,
                    photo: app.licensePhoto,
                    onPicked: (photo) => app.markLicenseUploaded(photo: photo),
                    onRemove: app.clearLicense,
                  ),
                  const SizedBox(height: 20),
                  const InfoBanner('Vos documents sont chiffrés et utilisés uniquement pour la vérification.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Says plainly what is outstanding and what it costs, rather than letting the
/// user work it out from two badges.
class _MissingNotice extends StatelessWidget {
  const _MissingNotice({required this.missing});

  final String missing;

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
            Icon(Icons.error_outline_rounded, size: 19, color: context.p.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Vérification incomplète', style: AppText.body(13.5, weight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(
                    'Il manque $missing. Tant que ce n\'est pas fait, vous pouvez '
                    'parcourir la flotte mais pas réserver.',
                    style: AppText.body(12, color: context.p.infoText, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DocSection extends StatelessWidget {
  const _DocSection({
    required this.title,
    required this.state,
    required this.photo,
    required this.onPicked,
    required this.onRemove,
  });

  final String title;
  final VerifyState state;
  final CapturedPhoto? photo;
  final ValueChanged<CapturedPhoto> onPicked;
  final VoidCallback onRemove;

  Future<void> _import(BuildContext context) async {
    final source = await choosePhotoSource(context);
    if (source == null || !context.mounted) return;
    final picked = await pickPhoto(context, source);
    if (picked == null || !context.mounted) return;
    onPicked(picked);
    showAppToast(context, '$title envoyé');
  }

  @override
  Widget build(BuildContext context) {
    final badge = verifyBadge(context, state, missingLabel: 'À fournir');
    final supplied = state != VerifyState.missing;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppText.body(14, weight: FontWeight.w600))),
              StatusPill(label: badge.label, background: badge.bg, foreground: badge.fg, fontSize: 10),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Thumb(label: 'Recto', photo: photo)),
              const SizedBox(width: 10),
              // Only the first capture is real; the verso slot stays a
              // placeholder until two-sided capture exists.
              Expanded(child: _Thumb(label: 'Verso', photo: null, filled: supplied)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: supplied ? 'Réimporter' : 'Importer',
                  height: 44,
                  onPressed: () => _import(context),
                ),
              ),
              if (supplied) ...[
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  width: 44,
                  child: Material(
                    color: context.p.redSurface,
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    child: InkWell(
                      onTap: () {
                        onRemove();
                        showAppToast(context, '$title supprimé');
                      },
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      child: Icon(Icons.delete_outline_rounded, size: 19, color: context.p.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.label, required this.photo, this.filled = false});

  final String label;
  final CapturedPhoto? photo;

  /// A slot with no image of its own but belonging to a supplied document.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final image = photoImage(photo);

    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.p.field,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: context.p.border),
        ),
        child: image ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  filled ? Icons.description_outlined : Icons.add_photo_alternate_outlined,
                  size: 22,
                  color: context.p.mutedLight,
                ),
                const SizedBox(height: 6),
                Text(label, style: AppText.body(11, weight: FontWeight.w600, color: context.p.labelIdle)),
              ],
            ),
      ),
    );
  }
}
