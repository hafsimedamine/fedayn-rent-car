// Getting a photo out of the device: camera, gallery, and showing one back.
//
// Not document-specific — the CIN and licence steps use it, and so does the
// profile picture on Compte.

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models.dart';
import '../theme.dart';
import 'common.dart';

export '../data/models.dart' show CapturedPhoto;

/// Android can kill the activity while the camera intent is in the foreground,
/// which loses the result. The plugin caches it; this recovers it on the way
/// back in. No-op on every other platform.
Future<CapturedPhoto?> recoverLostPhoto() async {
  if (kIsWeb || !Platform.isAndroid) return null;
  try {
    final response = await ImagePicker().retrieveLostData();
    if (response.isEmpty || response.file == null) return null;
    final file = response.file!;
    return CapturedPhoto(path: file.path, bytes: null);
  } on Exception {
    return null;
  }
}

/// Opens the camera, or the gallery, and returns what was captured.
/// Returns null if the user backs out or the platform refuses.
Future<CapturedPhoto?> pickPhoto(BuildContext context, ImageSource source) async {
  try {
    final file = await ImagePicker().pickImage(
      source: source,
      // A document photo only needs enough resolution to be legible; capping
      // it keeps a 12MP camera shot from being held in memory whole.
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file == null) return null;
    return CapturedPhoto(path: file.path, bytes: kIsWeb ? await file.readAsBytes() : null);
  } on Exception {
    // No camera, permission refused, or no picker on this platform.
    if (context.mounted) {
      showAppToast(
        context,
        source == ImageSource.camera
            ? "Impossible d'ouvrir l'appareil photo."
            : "Impossible d'ouvrir la galerie.",
      );
    }
    return null;
  }
}

/// The photo itself where we have one, null otherwise — callers supply their
/// own frame and fallback.
///
/// `errorBuilder` throughout: a file the OS has since moved or revoked access
/// to should degrade to the caller's fallback, not throw mid-build.
Widget? photoImage(CapturedPhoto? photo, {BoxFit fit = BoxFit.cover}) {
  if (photo == null) return null;
  final bytes = photo.bytes;
  if (bytes != null) {
    return Image.memory(bytes, fit: fit, errorBuilder: (_, __, ___) => const SizedBox.shrink());
  }
  // Web paths are blob URLs that Image.file cannot open.
  if (kIsWeb) return null;
  return Image.file(File(photo.path), fit: fit, errorBuilder: (_, __, ___) => const SizedBox.shrink());
}

/// Asks where the photo should come from. Returns null if the user backs out.
///
/// The verification steps show the two capture cards inline, so they do not
/// need this; anywhere the import is a single button does.
Future<ImageSource?> choosePhotoSource(BuildContext context) => showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.p.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: sheetContext.p.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            Text('Ajouter une photo', style: AppText.heading(18)),
            const SizedBox(height: 14),
            _SourceRow(
              icon: Icons.photo_camera_outlined,
              label: 'Prendre une photo',
              subtitle: 'Ouvre l\'appareil photo',
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            _SourceRow(
              icon: Icons.image_outlined,
              label: 'Choisir dans la galerie',
              subtitle: 'Depuis vos photos existantes',
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.icon, required this.label, required this.subtitle, required this.onTap});

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: context.p.chipBg, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: context.p.navy),
        ),
        title: Text(label, style: AppText.body(14.5, weight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppText.body(12, color: context.p.muted)),
      );
}

