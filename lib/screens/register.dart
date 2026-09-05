import 'package:flutter/material.dart';

import '../data/db/auth_repository.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../data/password_policy.dart';
import '../widgets/fields.dart';
import '../widgets/form_gate.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/social_buttons.dart';
import 'login.dart';
import 'verify_cin.dart';

/// Step 1 of 3 — account details.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure = true;
  bool _terms = false;
  bool _busy = false;
  String? _formError;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _pw, _pw2]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _confirmError(String v) {
    if (v.isEmpty) return 'Confirmez votre mot de passe';
    return v == _pw.text ? null : 'Les deux mots de passe ne correspondent pas';
  }

  bool get _canSubmit =>
      !_busy &&
      V.name(_name.text) == null &&
      V.email(_email.text) == null &&
      V.phone(_phone.text) == null &&
      V.pw(_pw.text) == null &&
      _confirmError(_pw2.text) == null &&
      _terms;

  /// Remplit les deux champs et les révèle : un mot de passe généré qu'on ne
  /// peut pas lire ne sert à rien, puisque l'utilisateur doit le noter.
  void _generatePassword() {
    final generated = PasswordPolicy.generate();
    setState(() {
      _pw.text = generated;
      _pw2.text = generated;
      _obscure = false;
    });
    showAppToast(context, 'Mot de passe généré — notez-le avant de continuer');
  }

  Future<void> _submit() async {
    final app = AppScope.read(context);
    final auth = app.auth;

    void toVerification() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VerifyCinScreen()),
        );

    // No store wired (previews): carry on into the flow as before.
    if (auth == null) {
      toVerification();
      return;
    }

    setState(() {
      _busy = true;
      _formError = null;
    });
    try {
      final account = await runWithLoading(
        context,
        () => auth.register(
          fullName: _name.text,
          email: _email.text,
          phone: _phone.text,
          password: _pw.text,
        ),
        message: 'Création du compte…',
      );
      if (!mounted) return;
      app.signedInAs(account);
      toVerification();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _formError = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackChevron(onTap: () => Navigator.of(context).maybePop()),
                  const StepIndicator(step: 1),
                ],
              ),
              const SizedBox(height: 16),
              const Center(child: BrandLogo(size: 40)),
              const SizedBox(height: 20),
              Text('Créer votre compte', style: AppText.heading(26)),
              const SizedBox(height: 6),
              Text('Réservez votre première voiture en quelques minutes.',
                  style: AppText.body(15, color: context.p.muted, height: 1.5)),
              const SizedBox(height: 26),
              AppField(label: 'Nom complet', controller: _name, validator: V.name, keyboardType: TextInputType.name),
              const SizedBox(height: 14),
              AppField(label: 'Adresse e-mail', controller: _email, validator: V.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              AppField(label: 'Numéro de téléphone', controller: _phone, validator: V.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              AppField(
                label: 'Mot de passe',
                controller: _pw,
                validator: V.pw,
                obscure: _obscure,
                trailing: PwToggle(obscured: _obscure, onTap: () => setState(() => _obscure = !_obscure)),
              ),
              const SizedBox(height: 8),
              const _PasswordHint(),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Générer un mot de passe',
                height: 46,
                onPressed: _generatePassword,
              ),
              const SizedBox(height: 14),
              AppField(
                label: 'Confirmer le mot de passe',
                controller: _pw2,
                validator: _confirmError,
                obscure: _obscure,
                trailing: PwToggle(obscured: _obscure, onTap: () => setState(() => _obscure = !_obscure)),
              ),
              const SizedBox(height: 18),
              AppCheckbox(
                value: _terms,
                onChanged: (v) => setState(() => _terms = v),
                child: Text.rich(
                  TextSpan(
                    style: AppText.body(13, color: context.p.muted, height: 1.5),
                    children: [
                      const TextSpan(text: "J'accepte les "),
                      TextSpan(
                        text: "conditions d'utilisation",
                        style: AppText.body(13, weight: FontWeight.w600, height: 1.5).copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'politique de confidentialité',
                        style: AppText.body(13, weight: FontWeight.w600, height: 1.5).copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_formError != null) ...[
                const SizedBox(height: 16),
                FormErrorBanner(message: _formError!),
              ],
              const SizedBox(height: 20),
              FormGate(
                listenTo: [_name, _email, _phone, _pw, _pw2],
                test: () => _canSubmit,
                builder: (_, enabled) => PrimaryButton(
                  label: _busy ? 'Création…' : 'Créer un compte',
                  enabled: enabled,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 12),
              const TrustNote('Vos données sont chiffrées et sécurisées', center: true),
              const SizedBox(height: 22),
              const SocialSection(stacked: false),
              const SizedBox(height: 24),
              AuthSwitchLine(
                prompt: 'Vous avez déjà un compte ?',
                action: 'Se connecter',
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rappelle les trois règles sous le champ, plutôt que de les révéler une par
/// une sous forme d'erreur après coup.
class _PasswordHint extends StatelessWidget {
  const _PasswordHint();

  @override
  Widget build(BuildContext context) => Text(
        'Au moins ${PasswordPolicy.minLength} caractères, une majuscule et un symbole.',
        style: AppText.body(11.5, color: context.p.mutedLight, height: 1.4),
      );
}
