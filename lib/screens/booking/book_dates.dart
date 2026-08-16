// Booking step 1 — dates, times and locations.

import 'package:flutter/material.dart';

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
  /// Tapping a day sets pickup, then return; a third tap restarts the range.
  void _pickDay(BookingDraft d, int day) {
    setState(() {
      final p = d.pickDay, r = d.retDay;
      if (p == null || r != null) {
        d.pickDay = day;
        d.retDay = null;
      } else if (day > p) {
        d.retDay = day;
      } else {
        d.pickDay = day;
        d.retDay = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = app.draft;
    final canContinue = d.pickDay != null && d.retDay != null && !d.hasDateConflict;

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
                  _Calendar(draft: d, onPick: (day) => _pickDay(d, day)),
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
                          const Icon(Icons.error_outline_rounded, size: 17, color: AppColors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Ces dates ne sont pas disponibles.',
                                style: AppText.body(12.5, weight: FontWeight.w500, color: AppColors.red)),
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
                    style: AppText.heading(15, color: AppColors.accent, weight: FontWeight.w700)),
                Text('/jour', style: AppText.body(11, color: context.p.mutedLight)),
              ],
            ),
          ],
        ),
      );
}

/// July 2026 month grid. Booked days are struck out and untappable.
class _Calendar extends StatelessWidget {
  const _Calendar({required this.draft, required this.onPick});

  final BookingDraft draft;
  final ValueChanged<int> onPick;

  static const _daysInMonth = 31;
  static const _firstWeekday = 3; // 1 July 2026 is a Wednesday

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (var i = 0; i < _firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (var day = 1; day <= _daysInMonth; day++) {
      final booked = kBookedDays.contains(day);
      final past = day < kToday;
      final disabled = booked || past;

      final isPick = draft.pickDay == day;
      final isRet = draft.retDay == day;
      final inRange = draft.pickDay != null &&
          draft.retDay != null &&
          day > draft.pickDay! &&
          day < draft.retDay!;
      final selected = isPick || isRet;

      cells.add(
        GestureDetector(
          onTap: disabled ? null : () => onPick(day),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent
                  : inRange
                      ? context.p.accentSurface
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: AppText.body(
                13,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? Colors.white
                    : disabled
                        ? context.p.grayDot
                        : context.p.navy,
              ).copyWith(decoration: booked ? TextDecoration.lineThrough : null),
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
          Text('Juillet 2026', style: AppText.body(14, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final d in ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
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
