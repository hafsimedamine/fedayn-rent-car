import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/accueil.dart';
import 'screens/favoris.dart';
import 'screens/welcome.dart';

void main() => runApp(const LocaDriveApp());

class LocaDriveApp extends StatelessWidget {
  const LocaDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fedayn's Rent Car",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const WelcomePage(),
    );
  }
}

class AccueilShell extends StatefulWidget {
  const AccueilShell({super.key});

  @override
  State<AccueilShell> createState() => _AccueilShellState();
}

class _AccueilShellState extends State<AccueilShell> {
  int _index = 0;
  final Set<String> _favoris = {};

  void _toggleFavori(String id) {
    setState(() {
      _favoris.contains(id) ? _favoris.remove(id) : _favoris.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      AccueilPage(favoris: _favoris, onToggleFavori: _toggleFavori),
      const _EnConstruction(
          titre: 'Mes locations', icone: Icons.vpn_key_outlined),
      FavorisPage(
        favoris: _favoris,
        onToggleFavori: _toggleFavori,
        onParcourir: () => setState(() => _index = 0),
      ),
      const _EnConstruction(
          titre: 'Mon compte', icone: Icons.person_outline_rounded),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.vpn_key_outlined),
              activeIcon: Icon(Icons.vpn_key_rounded),
              label: 'Locations'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoris'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Compte'),
        ],
      ),
    );
  }
}

/// Placeholder pour les onglets pas encore développés.
class _EnConstruction extends StatelessWidget {
  final String titre;
  final IconData icone;
  const _EnConstruction({required this.titre, required this.icone});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 60, color: AppColors.border),
              const SizedBox(height: 14),
              Text(titre,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Écran à venir',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}
