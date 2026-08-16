// Bottom-nav shell holding the four main tabs.

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'tabs/account_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/rentals_tab.dart';
import 'tabs/saved_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShell> createState() => MainShellState();

  /// Lets a child tab switch tabs (e.g. Saved's empty state -> Home).
  static MainShellState of(BuildContext context) => context.findAncestorStateOfType<MainShellState>()!;
}

class MainShellState extends State<MainShell> {
  late int _index = widget.initialTab;

  void goToTab(int i) {
    dismissAppToasts();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeTab(), RentalsTab(), SavedTab(), AccountTab()],
      ),
      bottomNavigationBar: _BottomNav(index: _index, onTap: goToTab),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Accueil'),
    (Icons.vpn_key_outlined, Icons.vpn_key_rounded, 'Locations'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Favoris'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Compte'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.p.surface,
        border: Border(top: BorderSide(color: context.p.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            i == index ? _items[i].$2 : _items[i].$1,
                            size: 22,
                            color: i == index ? AppColors.accent : context.p.mutedLight,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _items[i].$3,
                            style: AppText.body(10.5,
                                weight: FontWeight.w600,
                                color: i == index ? AppColors.accent : context.p.mutedLight),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
