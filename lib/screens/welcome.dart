import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'login.dart';
import 'register.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Column(
        children: [
          const _Hero(),
          // Lays out as designed when there is room — the Spacer pushes the CTAs
          // to the bottom — and scrolls rather than clipping when there is not
          // (small phones, split screen, large text scale).
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(child: _Content()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          const BrandLogo(size: 52, dark: true),
          const SizedBox(height: 26),
          Text(
            'La voiture idéale pour chaque trajet.',
            textAlign: TextAlign.center,
            style: AppText.heading(30, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 10),
          Text(
            'Parcourez la flotte, réservez par date et payez en ligne — récupérez et partez.',
            textAlign: TextAlign.center,
            style: AppText.body(15, color: Colors.white.withValues(alpha: 0.62), height: 1.55),
          ),
          const Spacer(),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Créer un compte',
            foreground: AppColors.navyDark,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Se connecter',
            dark: true,
            height: 54,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
          const SizedBox(height: 16),
          // One line at any width — scales down rather than clipping.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Annulation gratuite  ·  Assistance 24/7  ·  Paiement sécurisé',
              maxLines: 1,
              style: AppText.body(12, weight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.42)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  /// Space the copy + CTA stack wants before the content starts scrolling.
  static const _contentMin = 430.0;

  @override
  Widget build(BuildContext context) {
    // The design pins the hero at 46%, which overflows once the viewport is
    // ~844pt or shorter (and safe areas make that worse on device). Take 46%
    // only when the content still fits, otherwise yield the difference.
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final available = size.height - padding.top - padding.bottom;
    final h = math.max(200.0, math.min(available * 0.46, available - _contentMin));

    return SizedBox(
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The design's hero slot called for a "stylish car / open road".
          Image.asset(
            'assets/images/hero.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.navyDark),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.3, 0.55, 0.82, 1.0],
                colors: [
                  Color(0x590A1B2E),
                  Color(0x000A1B2E),
                  Color(0x000A1B2E),
                  Color(0x8C0A1B2E),
                  Color(0xFF0A1B2E),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
