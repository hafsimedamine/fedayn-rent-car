import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../data/flotte.dart';
import '../models/voiture.dart';
import '../widgets/carte_voiture.dart';

class AccueilPage extends StatefulWidget {
  final Set<String> favoris;
  final void Function(String id) onToggleFavori;

  const AccueilPage({
    super.key,
    required this.favoris,
    required this.onToggleFavori,
  });

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  Categorie? _filtre;
  String _recherche = '';

  List<Voiture> get _resultats {
    return flotte.where((v) {
      final okCat = _filtre == null || v.categorie == _filtre;
      final q = _recherche.trim().toLowerCase();
      final okRech = q.isEmpty ||
          v.nomComplet.toLowerCase().contains(q) ||
          v.agence.toLowerCase().contains(q);
      return okCat && okRech;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final res = _resultats;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ---------- En-tête ----------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bonjour, Youssef 👋',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Trouvez votre voiture idéale',
                            style: TextStyle(
                                fontSize: 14.5,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),

          // ---------- Recherche ----------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: TextField(
                onChanged: (v) => setState(() => _recherche = v),
                decoration: InputDecoration(
                  hintText: 'Rechercher par modèle, marque ou lieu',
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide:
                        const BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // ---------- Filtres ----------
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                children: [
                  _chip('Tout', _filtre == null,
                      () => setState(() => _filtre = null)),
                  for (final c in Categorie.values)
                    _chip(c.label, _filtre == c,
                        () => setState(() => _filtre = c)),
                ],
              ),
            ),
          ),

          // ---------- Titre section ----------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              child: Row(
                children: [
                  const Text('Voitures disponibles',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${res.length} résultats',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),

          // ---------- Liste ----------
          if (res.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 52, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text('Aucune voiture trouvée',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Essayez un autre filtre ou une autre recherche',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.builder(
                itemCount: res.length,
                itemBuilder: (_, i) {
                  final v = res[i];
                  return CarteVoiture(
                    voiture: v,
                    favori: widget.favoris.contains(v.id),
                    onFavori: () {
                      widget.onToggleFavori(v.id);
                      final ajoute = !widget.favoris.contains(v.id);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(ajoute
                              ? 'Ajoutée aux favoris'
                              : 'Retirée des favoris'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ));
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String texte, bool actif, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: actif ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                  color: actif ? AppColors.accent : AppColors.border),
            ),
            child: Text(
              texte,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: actif ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
}
