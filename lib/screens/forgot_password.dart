import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/form_gate.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerLeft, child: BackChevron(onTap: () => Navigator.of(context).maybePop())),
              Expanded(child: _sent ? _sentView() : _formView()),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: AppText.body(14, weight: FontWeight.w500, color: context.p.muted),
                    children: [
                      const TextSpan(text: 'Vous vous en souvenez ? '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Text('Se connecter',
                              style: AppText.body(14, weight: FontWeight.w600, color: context.p.accent)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formView() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 26),
          Text('Réinitialiser votre mot de passe', style: AppText.heading(26)),
          const SizedBox(height: 8),
          Text("Saisissez l'e-mail utilisé lors de l'inscription et nous vous enverrons un lien de réinitialisation.",
              style: AppText.body(15, color: context.p.muted, height: 1.55)),
          const SizedBox(height: 28),
          AppField(label: 'Adresse e-mail', controller: _email, validator: V.email, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 22),
          FormGate(
            listenTo: [_email],
            test: () => V.email(_email.text) == null,
            builder: (_, enabled) => PrimaryButton(
              label: 'Envoyer le lien',
              enabled: enabled,
              onPressed: () => setState(() => _sent = true),
            ),
          ),
        ],
      );

  Widget _sentView() => Column(
        children: [
          const SizedBox(height: 70),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: context.p.greenSurface, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, size: 34, color: context.p.green),
          ),
          const SizedBox(height: 22),
          Text('Consultez votre boîte mail', style: AppText.heading(22)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Text.rich(
              TextSpan(
                style: AppText.body(15, color: context.p.muted, height: 1.55),
                children: [
                  const TextSpan(text: 'Nous avons envoyé un lien de réinitialisation à '),
                  TextSpan(text: _email.text, style: AppText.body(15, weight: FontWeight.w600, height: 1.55)),
                  const TextSpan(text: '. Il expire dans 30 minutes.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Text('Retour à la connexion',
                style: AppText.body(15, weight: FontWeight.w600, color: context.p.accent)),
          ),
        ],
      );
}
