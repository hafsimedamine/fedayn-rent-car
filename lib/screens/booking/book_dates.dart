// Booking step 1 — dates, times and locations.

import 'package:flutter/material.dart';

import '../../data/calendar.dart';
import '../../data/fleet.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/car_card.dart';
import '../../widgets/common.dart';
import '../../widgets/fields.dart';
import 'book_review.dart';

class BookDatesScreen extends StatefulWidget {
  const BookDatesScreen({super.key});

  @override
  State<BookDatesScreen> createState() => _BookDatesScreenState();
}

class _BookDatesScreenState extends State<BookDatesScreen> {
  /// Un appui fixe le départ, le suivant le retour ; un troisième recommence.
  void _pickDay(BookingDraft d, DateTime jour) {
    setState(() {
      final p = d.pickDate, r = d.retDate;
      if (p == null || r != null) {
        d.pickDate = jour;
        d.retDate = null;
      } else if (jour.isAfter(p)) {
        d.retDate = jour;
      } else {
        d.pickDate = jour;
        d.retDate = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = app.draft;
    final canContinue = d.pickDate != null && d.retDate != null && !d.hasDateConflict;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Réservez votre voiture', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                children: [
                  _CarSummary(draft: d),
                  const SizedBox(height: 22),
                  const SectionLabel('DATES DE LOCATION'),
                  const SizedBox(height: 12),
                  _Calendar(draft: d, onPick: (jour) => _pickDay(d, jour)),
                  if (d.hasDateConflict) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.p.redSurface,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        border: Border.all(color: context.p.redBorder, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, size: 17, color: context.p.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Ces dates ne sont pas disponibles.',
                                style: AppText.body(12.5, weight: FontWeight.w500, color: context.p.red)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdown<String>(
                          label: 'Heure de départ',
                          value: d.pickTime,
                          items: kTimes,
                          onChanged: (v) => setState(() => d.pickTime = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppDropdown<String>(
                          label: 'Heure de retour',
                          value: d.retTime,
                          items: kTimes,
                          onChanged: (v) => setState(() => d.retTime = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('LIEUX'),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: 'Lieu de prise en charge',
                    value: d.pickLoc,
                    items: kLocations,
                    onChanged: (v) => setState(() => d.pickLoc = v),
                  ),
                  const SizedBox(height: 12),
                  AppCheckbox(
                    value: d.retSameAsPick,
                    onChanged: (v) => setState(() => d.retSameAsPick = v),
                    child: Text('Retour au même endroit', style: AppText.body(13.5, weight: FontWeight.w500)),
                  ),
                  if (!d.retSameAsPick) ...[
                    const SizedBox(height: 12),
                    AppDropdown<String>(
                      label: 'Lieu de retour',
                      value: d.retLoc,
                      items: kLocations,
                      onChanged: (v) => setState(() => d.retLoc = v),
                    ),
                  ],
                ],
              ),
            ),
            StickyBar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (d.days > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${d.days} jours × ${fmtMad(d.car.price)} MAD',
                              style: AppText.body(13, color: context.p.muted)),
                          Text('${fmtMad(d.base)} MAD', style: AppText.body(15, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  PrimaryButton(
                    label: 'Continuer',
                    enabled: canContinue,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BookReviewScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarSummary extends StatelessWidget {
  const _CarSummary({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.cardBorder),
        ),
        child: Row(
          children: [
            CarThumb(car: draft.car, width: 84, height: 62),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(draft.car.name, style: AppText.body(14.5, weight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('${catFr(draft.car.cat)} • ${transFr(draft.car.trans)}',
                      style: AppText.body(11.5, color: context.p.mutedLight)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${fmtMad(draft.car.price)} MAD',
                    style: AppText.heading(15, color: context.p.accent, weight: FontWeight.w700)),
                Text('/jour', style: AppText.body(11, color: context.p.mutedLight)),
              ],
            ),
          ],
        ),
      );
}

/// Grille mensuelle réelle, avec navigation d'un mois à l'autre.
///
/// Remplace une grille figée sur juillet 2026 : 31 cases, un « aujourd'hui »
/// constant au 13 et un premier jour codé au mercredi.
class _Calendar extends StatefulWidget {
  const _Calendar({required this.draft, required this.onPick});

  final BookingDraft draft;
  final ValueChanged<DateTime> onPick;

  @override
  State<_Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  /// Le mois affiché, toujours normalisé au 1er.
  late DateTime _mois = DateTime(aujourdHui.year, aujourdHui.month, 1);

  /// On ne remonte pas avant le mois courant, et on ne dépasse pas un an :
  /// réserver pour dans dix-huit mois n'a pas de sens pour une location.
  DateTime get _premierMois => DateTime(aujourdHui.year, aujourdHui.month, 1);
  DateTime get _dernierMois => moisDecale(_premierMois, 11);

  bool get _peutReculer => _mois.isAfter(_premierMois);
  bool get _peutAvancer => _mois.isBefore(_dernierMois);

  void _changerMois(int delta) => setState(() => _mois = moisDecale(_mois, delta));

  String get _titre {
    final nom = kMoisFr[_mois.month - 1];
    return '${nom[0].toUpperCase()}${nom.substring(1)} ${_mois.year}';
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final today = aujourdHui;
    final nbJours = joursDansLeMois(_mois.year, _mois.month);
    final decalage = decalagePremierJour(_mois.year, _mois.month);

    final cells = <Widget>[for (var i = 0; i < decalage; i++) const SizedBox()];

    for (var numero = 1; numero <= nbJours; numero++) {
      final jour = DateTime(_mois.year, _mois.month, numero);
      final reserve = draft.indisponibles.contains(jour);
      final passe = jour.isBefore(today);
      final desactive = reserve || passe;

      final estDepart = draft.pickDate != null && memeJour(draft.pickDate!, jour);
      final estRetour = draft.retDate != null && memeJour(draft.retDate!, jour);
      final dansLaPeriode = draft.pickDate != null &&
          draft.retDate != null &&
          jour.isAfter(draft.pickDate!) &&
          jour.isBefore(draft.retDate!);
      final selectionne = estDepart || estRetour;

      cells.add(
        GestureDetector(
          onTap: desactive ? null : () => widget.onPick(jour),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: selectionne
                  ? context.p.accent
                  : dansLaPeriode
                      ? context.p.accentSurface
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              // Aujourd'hui reste repérable même quand il n'est pas choisi.
              border: !selectionne && memeJour(jour, today)
                  ? Border.all(color: context.p.accent, width: 1.2)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$numero',
              style: AppText.body(
                13,
                weight: selectionne ? FontWeight.w700 : FontWeight.w500,
                color: selectionne
                    ? context.p.onAccent
                    : desactive
                        ? context.p.grayDot
                        : context.p.navy,
              ).copyWith(decoration: reserve ? TextDecoration.lineThrough : null),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.p.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _FlecheMois(
                icone: Icons.chevron_left_rounded,
                libelle: 'Mois précédent',
                actif: _peutReculer,
                onTap: () => _changerMois(-1),
              ),
              Expanded(child: Center(child: Text(_titre, style: AppText.body(14, weight: FontWeight.w600)))),
              _FlecheMois(
                icone: Icons.chevron_right_rounded,
                libelle: 'Mois suivant',
                actif: _peutAvancer,
                onTap: () => _changerMois(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final d in kJoursCourtsFr)
                Expanded(
                  child: Center(
                    child: Text(d, style: AppText.body(11, weight: FontWeight.w600, color: context.p.mutedLight)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: cells,
          ),
        ],
      ),
    );
  }
}

class _FlecheMois extends StatelessWidget {
  const _FlecheMois({required this.icone, required this.libelle, required this.actif, required this.onTap});

  final IconData icone;
  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: libelle,
        child: InkWell(
          onTap: actif ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icone, size: 22, color: actif ? context.p.navy : context.p.grayDot),
          ),
        ),
      );
}
