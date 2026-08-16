// The paired "Prendre une photo" (primary, accent) / "Importer" (secondary)
// capture cards used on the CIN and driver's licence steps, plus the shared
// plumbing for actually getting a photo out of the device.

import 'package:flutter/material.dart';

import '../theme.dart';
import 'photo_picker.dart';

// photo_picker re-exports CapturedPhoto, so importing this file alone is
// enough for the verification screens.
export 'photo_picker.dart';

class CaptureOptions extends StatelessWidget {
  const CaptureOptions({
    super.key,
    required this.scanLabel,
    required this.onScan,
    required this.onUpload,
  });

  final String scanLabel;

  /// Take a photo now.
  final VoidCallback onScan;

  /// Choose an existing photo.
  final VoidCallback onUpload;

  @override
  // IntrinsicHeight bounds the cross axis: `stretch` inside a scroll view asks
  // for infinite height, which throws during layout and blanks the screen.
  // It also keeps the two cards the same height, as the design has them.
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 125,
              child: _CaptureCard(
                icon: Icons.photo_camera_outlined,
                iconColor: AppColors.accent,
                title: scanLabel,
                subtitle: 'Photo immédiate',
                background: context.p.accentSurface,
                borderColor: AppColors.accent,
                onTap: onScan,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 100,
              child: _CaptureCard(
                icon: Icons.image_outlined,
                iconColor: context.p.muted,
                title: 'Importer une photo',
                subtitle: 'Depuis votre galerie',
                background: context.p.surface,
                borderColor: context.p.border,
                onTap: onUpload,
              ),
            ),
          ],
        ),
      );
}

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color background;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26, color: iconColor),
                const SizedBox(height: 8),
                Text(title, style: AppText.body(15, weight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(subtitle, style: AppText.body(12, color: context.p.muted, height: 1.4)),
              ],
            ),
          ),
        ),
      );
}

/// The "2 photos · importées" row with a remove button.
class UploadedRow extends StatelessWidget {
  const UploadedRow({super.key, required this.filename, required this.onRemove, this.photo});

  final String filename;
  final VoidCallback onRemove;

  /// Shown as the thumbnail when the user supplied a real photo.
  final CapturedPhoto? photo;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: context.p.border, width: 1.5),
        ),
        child: Row(
          children: [
            _Thumbnail(photo: photo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filename, style: AppText.body(13, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(photo != null ? 'Photo ajoutée' : '2 photos · importées',
                      style: AppText.body(11, color: context.p.mutedLight)),
                ],
              ),
            ),
            InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: context.p.chipBg, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, size: 14, color: context.p.muted),
              ),
            ),
          ],
        ),
      );
}

/// Thumbnail for the uploaded row: the real photo where we have one, and the
/// neutral document icon otherwise (previews, or a pick that returned no data).
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.photo});

  final CapturedPhoto? photo;

  @override
  Widget build(BuildContext context) {
    final image = photoImage(photo);

    return Container(
      width: 56,
      height: 38,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.p.field,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.p.border),
      ),
      child: image ?? Icon(Icons.description_outlined, size: 18, color: context.p.mutedLight),
    );
  }
}
