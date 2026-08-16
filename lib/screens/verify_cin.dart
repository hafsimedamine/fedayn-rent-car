// Step 2 of 3 — CIN (national ID) verification.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/fleet.dart';
import '../theme.dart';
import '../widgets/capture_cards.dart';
import '../widgets/common.dart';
import '../state/app_state.dart';
import '../widgets/fields.dart';
import '../widgets/skip_verification.dart';
import 'main_shell.dart';
import 'verify_license.dart';

class VerifyCinScreen extends StatefulWidget {
  const VerifyCinScreen({super.key});

  @override
  State<VerifyCinScreen> createState() => _VerifyCinScreenState();
}

class _VerifyCinScreenState extends State<VerifyCinScreen> {
  final _num = TextEditingController();
  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _exp = TextEditingController();

  bool _captured = false;
  bool _autoFilled = false;
  CapturedPhoto? _photo;

  @override
  void initState() {
    super.initState();
    // Pick up a capture that survived the activity being killed mid-intent.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final recovered = await recoverLostPhoto();
      if (recovered == null || !mounted) return;
      _applyScanResult(photo: recovered);
      AppScope.read(context).markCinUploaded(photo: recovered);
    });
  }

  @override
  void dispose() {
    for (final c in [_num, _name, _dob, _exp]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Populates the fields the way a successful scan would. There is no OCR
  /// behind this yet — the photo is real, the extracted values are fixtures.
  void _applyScanResult({CapturedPhoto? photo}) {
    setState(() {
      _captured = true;
      _photo = photo;
      _autoFilled = true;
      _num.text = kDemoCinNumber;
      _name.text = kDemoCinName;
      _dob.text = kDemoCinBirthDate;
      _exp.text = kDemoCinExpiry;
    });
  }

  Future<void> _capture(ImageSource source) async {
    final photo = await pickPhoto(context, source);
    if (photo == null || !mounted) return;
    _applyScanResult(photo: photo);
    AppScope.read(context).markCinUploaded(photo: photo);
  }

  Future<void> _skip() async {
    if (!await confirmSkipVerification(context) || !mounted) return;
    // Straight to the app; both documents stay outstanding and renting is
    // locked until they are supplied.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  BackChevron(onTap: () => Navigator.of(context).maybePop()),
                  const Spacer(),
                  const StepIndicator(step: 2),
                  const SizedBox(width: 4),
                  SkipLink(onTap: _skip),
                ],
              ),
              const SizedBox(height: 24),
              Text('Vérifier votre identité', style: AppText.heading(26)),
              const SizedBox(height: 6),
              Text('Nous avons besoin de votre CIN pour confirmer votre éligibilité à la location.',
                  style: AppText.body(15, color: context.p.muted, height: 1.5)),
              const SizedBox(height: 10),
              const TrustNote('Vérification sécurisée et chiffrée'),
              const SizedBox(height: 22),
              CaptureOptions(
                scanLabel: 'Prendre une photo',
                onScan: () => _capture(ImageSource.camera),
                onUpload: () => _capture(ImageSource.gallery),
              ),
              if (_captured) ...[
                const SizedBox(height: 14),
                UploadedRow(
                  filename: _photo?.fileName ?? 'cin_front_back.jpg',
                  photo: _photo,
                  onRemove: () => setState(() {
                    _captured = false;
                    _photo = null;
                    _autoFilled = false;
                    for (final c in [_num, _name, _dob, _exp]) {
                      c.clear();
                    }
                  }),
                ),
              ],
              const SizedBox(height: 24),
              const SectionLabel('DÉTAILS DE LA PIÈCE'),
              const SizedBox(height: 12),
              AppField(label: 'Numéro de CIN', controller: _num, autoFilled: _autoFilled),
              const SizedBox(height: 14),
              AppField(label: 'Nom complet (comme sur la pièce)', controller: _name, autoFilled: _autoFilled),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppField(label: 'Date de naissance', controller: _dob, autoFilled: _autoFilled, compactBadge: true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppField(label: "Date d'expiration", controller: _exp, autoFilled: _autoFilled, compactBadge: true),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const InfoBanner('Vos documents sont chiffrés et utilisés uniquement pour la vérification.'),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Continuer',
                enabled: _captured,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VerifyLicenseScreen()),
                ),
              ),
              const SizedBox(height: 10),
              SecondaryButton(label: 'Passer pour l\'instant', height: 52, onPressed: _skip),
            ],
          ),
        ),
      ),
    );
  }
}
