import 'package:flutter/material.dart';

import '../../data/db/auth_repository.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/fields.dart';
import '../../widgets/form_gate.dart';
import '../../widgets/loading_overlay.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final app = AppScope.read(context);
    _name = TextEditingController(text: app.piName);
    _phone = TextEditingController(text: app.piPhone);
    _email = TextEditingController(text: app.piEmail);
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _busy = false;
  String? _formError;

  Future<void> _save() async {
    final app = AppScope.read(context);
    final auth = app.auth;
    final account = app.account;
    final navigator = Navigator.of(context);

    Future<void> finish() async {
      app.savePersonalInfo(name: _name.text, phone: _phone.text, email: _email.text);
      navigator.maybePop();
      showAppToast(context, 'Informations mises à jour');
    }

    // Not signed in against a store (previews): keep the local update.
    if (auth == null || account == null) {
      await finish();
      return;
    }

    setState(() {
      _busy = true;
      _formError = null;
    });
    try {
      final updated = await runWithLoading(
        context,
        () => auth.updateProfile(
          id: account.id,
          fullName: _name.text,
          email: _email.text,
          phone: _phone.text,
        ),
        message: 'Enregistrement…',
      );
      if (!mounted) return;
      app.signedInAs(updated);
      navigator.maybePop();
      showAppToast(context, 'Informations mises à jour');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _formError = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool get _valid =>
      V.name(_name.text) == null && V.phone(_phone.text) == null && V.email(_email.text) == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Informations personnelles', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                children: [
                  AppField(label: 'Nom complet', controller: _name, validator: V.name, keyboardType: TextInputType.name),
                  const SizedBox(height: 14),
                  AppField(label: 'Numéro de téléphone', controller: _phone, validator: V.phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),
                  AppField(label: 'Adresse e-mail', controller: _email, validator: V.email, keyboardType: TextInputType.emailAddress),
                  if (_formError != null) ...[
                    const SizedBox(height: 16),
                    FormErrorBanner(message: _formError!),
                  ],
                ],
              ),
            ),
            StickyBar(
              child: FormGate(
                listenTo: [_name, _phone, _email],
                test: () => _valid && !_busy,
                builder: (_, enabled) => PrimaryButton(
                  label: _busy ? 'Enregistrement…' : 'Enregistrer',
                  enabled: enabled,
                  onPressed: _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
