// Step 3 of 3 — driver's licence verification.

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
import 'success.dart';

class VerifyLicenseScreen extends StatefulWidget {
  const VerifyLicenseScreen({super.key});

  @override
  State<VerifyLicenseScreen> createState() => _VerifyLicenseScreenState();
}

class _VerifyLicenseScreenState extends State<VerifyLicenseScreen> {
  final _num = TextEditingController();
  final _issue = TextEditingController();
  final _exp = TextEditingController();

  String _country = kLicenseCountries.first;
  String _category = 'B';

  bool _captured = false;
  bool _autoFilled = false;
  CapturedPhoto? _photo;
  bool _confirmAccurate = false;
  bool _terms = false;

  @override
  void initState() {
    super.initState();
    // Pick up a capture that survived the activity being killed mid-intent.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final recovered = await recoverLostPhoto();
      if (recovered == null || !mounted) return;
      _applyScanResult(photo: recovered);
      AppScope.read(context).markLicenseUploaded(photo: recovered);
    });
  }

  @override
  void dispose() {
    for (final c in [_num, _issue, _exp]) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyScanResult({CapturedPhoto? photo}) {
    setState(() {
      _captured = true;
      _photo = photo;
      _autoFilled = true;
      _num.text = kDemoLicenseNumber;
      _issue.text = kDemoLicenseIssue;
      _exp.text = kDemoLicenseExpiry;
    });
  }

  Future<void> _capture(ImageSource source) async {
    final photo = await pickPhoto(context, source);
    if (photo == null || !mounted) return;
    _applyScanResult(photo: photo);
    AppScope.read(context).markLicenseUploaded(photo: photo);
  }

  Future<void> _skip() async {
    if (!await confirmSkipVerification(context) || !mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  bool get _canSubmit => _captured && _confirmAccurate && _terms;

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
                  const StepIndicator(step: 3),
                  const SizedBox(width: 4),
                  SkipLink(onTap: _skip),
                ],
              ),
              const SizedBox(height: 24),
              Text('Ajouter votre permis de conduire', style: AppText.heading(26)),
              const SizedBox(height: 6),
              Text('Obligatoire pour louer un véhicule.', style: AppText.body(15, color: context.p.muted, height: 1.5)),
              const SizedBox(height: 22),
              CaptureOptions(
                scanLabel: 'Prendre une photo',
                onScan: () => _capture(ImageSource.camera),
                onUpload: () => _capture(ImageSource.gallery),
              ),
              if (_captured) ...[
                const SizedBox(height: 14),
                UploadedRow(
                  filename: _photo?.fileName ?? 'license_front_back.jpg',
                  photo: _photo,
                  onRemove: () => setState(() {
                    _captured = false;
                    _photo = null;
                    _autoFilled = false;
                    for (final c in [_num, _issue, _exp]) {
                      c.clear();
                    }
                  }),
                ),
              ],
              const SizedBox(height: 24),
              const SectionLabel('DÉTAILS DU PERMIS'),
              const SizedBox(height: 12),
              AppField(label: 'Numéro de permis', controller: _num, autoFilled: _autoFilled),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: AppField(label: 'Date de délivrance', controller: _issue, autoFilled: _autoFilled, compactBadge: true)),
                  const SizedBox(width: 10),
                  Expanded(child: AppField(label: "Date d'expiration", controller: _exp, autoFilled: _autoFilled, compactBadge: true)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 14,
                    child: AppDropdown<String>(
                      label: 'Pays de délivrance',
                      value: _country,
                      items: kLicenseCountries,
                      onChanged: (v) => setState(() => _country = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 10,
                    child: AppDropdown<String>(
                      label: 'Catégorie',
                      value: _category,
                      items: kLicenseCategories,
                      onChanged: (v) => setState(() => _category = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppCheckbox(
                value: _confirmAccurate,
                onChanged: (v) => setState(() => _confirmAccurate = v),
                child: Text('Je confirme que toutes les informations fournies sont exactes',
                    style: AppText.body(13, color: context.p.muted, height: 1.5)),
              ),
              const SizedBox(height: 12),
              AppCheckbox(
                value: _terms,
                onChanged: (v) => setState(() => _terms = v),
                child: Text.rich(
                  TextSpan(
                    style: AppText.body(13, color: context.p.muted, height: 1.5),
                    children: [
                      const TextSpan(text: "J'accepte les "),
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppText.body(13, weight: FontWeight.w600, height: 1.5)
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: ' et '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppText.body(13, weight: FontWeight.w600, height: 1.5)
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Créer un compte',
                enabled: _canSubmit,
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SuccessScreen()),
                  (_) => false,
                ),
              ),
              const SizedBox(height: 10),
              SecondaryButton(label: 'Passer pour l\'instant', height: 52, onPressed: _skip),
              const SizedBox(height: 12),
              const TrustNote('Vos données sont chiffrées et sécurisées', center: true),
            ],
          ),
        ),
      ),
    );
  }
}
