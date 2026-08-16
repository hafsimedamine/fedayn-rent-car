import 'package:flutter/material.dart';

import '../data/db/auth_repository.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/form_gate.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/social_buttons.dart';
import 'forgot_password.dart';
import 'main_shell.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _formError;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_busy && V.email(_email.text) == null && V.req(_pw.text) == null;

  Future<void> _submit() async {
    final app = AppScope.read(context);
    final auth = app.auth;

    // No store wired (previews): fall through to the app as before.
    if (auth == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
      return;
    }

    setState(() {
      _busy = true;
      _formError = null;
    });
    try {
      final account = await runWithLoading(
        context,
        () => auth.signIn(email: _email.text, password: _pw.text),
        message: 'Connexion…',
      );
      if (!mounted) return;
      app.signedInAs(account);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
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
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerLeft, child: BackChevron(onTap: () => Navigator.of(context).maybePop())),
                const SizedBox(height: 20),
                const Center(child: BrandLogo(size: 40)),
                const SizedBox(height: 24),
                Text('Bon retour', style: AppText.heading(26)),
                const SizedBox(height: 6),
                Text('Connectez-vous pour gérer vos réservations.',
                    style: AppText.body(15, color: context.p.muted, height: 1.5)),
                const SizedBox(height: 30),
                AppField(label: 'Adresse e-mail', controller: _email, validator: V.email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                AppField(
                  label: 'Mot de passe',
                  controller: _pw,
                  validator: V.req,
                  obscure: _obscure,
                  trailing: PwToggle(obscured: _obscure, onTap: () => setState(() => _obscure = !_obscure)),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: Text('Mot de passe oublié ?', style: AppText.body(13, weight: FontWeight.w600)),
                  ),
                ),
                if (_formError != null) ...[
                  const SizedBox(height: 16),
                  FormErrorBanner(message: _formError!),
                ],
                const SizedBox(height: 22),
                // Only this button depends on what has been typed, so only
                // this button listens. Wiring the controllers to a screen-wide
                // setState rebuilt everything above on every character.
                FormGate(
                  listenTo: [_email, _pw],
                  test: () => _canSubmit,
                  builder: (_, enabled) => PrimaryButton(
                    label: _busy ? 'Connexion…' : 'Se connecter',
                    enabled: enabled,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 24),
                const SocialSection(),
                const SizedBox(height: 28),
                AuthSwitchLine(
                  prompt: "Nouveau sur Fedayn's ?",
                  action: 'Créer un compte',
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
