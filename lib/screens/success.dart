import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 46),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(color: context.p.greenSurface, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, size: 42, color: AppColors.green),
                    ),
                    const SizedBox(height: 26),
                    Text("Bienvenue sur Fedayn's Rent Car !", textAlign: TextAlign.center, style: AppText.heading(26)),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        'Votre compte est en cours de vérification. Vous pouvez explorer les voitures pendant l\'examen de vos documents.',
                        textAlign: TextAlign.center,
                        style: AppText.body(15, color: context.p.muted, height: 1.55),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: context.p.field,
                        borderRadius: BorderRadius.circular(AppRadius.field),
                        border: Border.all(color: context.p.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 18, color: AppColors.amber),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Vérification', style: AppText.body(13, weight: FontWeight.w600))),
                          StatusPill(
                            label: 'En attente',
                            background: context.p.amberSurface,
                            foreground: AppColors.amber,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: 'Commencer à explorer',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
