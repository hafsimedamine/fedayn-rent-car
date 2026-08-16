import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Écran d'accueil (welcome) — Fedayn's Rent Car
/// Reproduit la maquette : bloc logo métallisé en haut, zone sombre en bas
/// avec mini-logo, accroche, boutons et footer.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const SizedBox.expand(
            child: Column(
              children: [
                // Expanded(flex: 45, child: _HeroLogo()),
                Expanded(flex: 55, child: _BottomContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bloc du haut : fond métallisé + logo de la marque
// ---------------------------------------------------------------------------
class _HeroLogo extends StatelessWidget {
  const _HeroLogo();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB9C0C6),
            Color(0xFFE8EBEE),
            Color(0xFFF4F6F7),
            Color(0xFF9AA4AC),
            AppColors.primary,
          ],
          stops: [0.0, 0.22, 0.48, 0.82, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Image.asset(
            'assets/images/logo_fedayns.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const _HeroLogoFallback(),
          ),
        ),
      ),
    );
  }
}

/// Rendu de secours si l'asset du logo n'est pas encore présent.
class _HeroLogoFallback extends StatelessWidget {
  const _HeroLogoFallback();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.directions_car_rounded,
          size: 92,
          color: AppColors.primary,
        ),
        const SizedBox(height: 14),
        const Text(
          "FEDAYN'S",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            height: 1.0,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'RENT CAR',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
            height: 1.0,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 260,
          height: 1.5,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 10),
        const Text(
          'Location Automobile & Service Premium',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bloc du bas : zone sombre
// ---------------------------------------------------------------------------
class _BottomContent extends StatelessWidget {
  const _BottomContent();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 14),
          child: Column(
            children: [
              const _MiniLogo(),
              const SizedBox(height: 10),
              const Text(
                "Fedayn's Rent Car",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'LOCATION AUTOMOBILE & SERVICE PREMIUM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: AppColors.surface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'La voiture idéale pour chaque trajet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.22,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Parcourez la flotte, réservez par date et payez en ligne — récupérez et partez.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.surface.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 26),

              // Bouton principal — Créer un compte
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.field),
                    ),
                  ),
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bouton secondaire — Se connecter
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.surface,
                    backgroundColor: AppColors.primaryLight,
                    side: BorderSide(
                      color: AppColors.surface.withValues(alpha: 0.22),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.field),
                    ),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Annulation gratuite  ·  Assistance 24/7  ·  Paiement sécurisé',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.surface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini-logo : arc orange + voiture blanche
// ---------------------------------------------------------------------------
class _MiniLogo extends StatelessWidget {
  const _MiniLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 46,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 88,
            height: 44,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.accent, width: 2.5),
                left: BorderSide(color: AppColors.accent, width: 2.5),
                right: BorderSide(color: AppColors.accent, width: 2.5),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(44),
                topRight: Radius.circular(44),
              ),
            ),
          ),
          const Positioned(
            bottom: 2,
            child: Icon(
              Icons.directions_car_rounded,
              size: 26,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}
