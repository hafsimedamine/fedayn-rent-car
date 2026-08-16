// Sort/filter sheet, opened from the Home search bar's filter button and from
// the "Trier" label beside the section heading.

import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';

Future<void> showSortSheet(BuildContext context) {
  final app = AppScope.read(context);

  return showModalBottomSheet<void>(
    context: context,
    // Without this the sheet is capped at 9/16 of the screen and the last
    // option falls below the fold.
    isScrollControlled: true,
    backgroundColor: context.p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetContext.p.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Trier les voitures', style: AppText.heading(20)),
            const SizedBox(height: 4),
            Text(
              'Choisissez un ordre d’affichage',
              style: AppText.body(13, color: sheetContext.p.muted),
            ),
            const SizedBox(height: 16),
            for (final mode in SortMode.values)
              _SortRow(
                mode: mode,
                selected: app.sort == mode,
                onTap: () {
                  app.setSort(mode);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    ),
  );
}

class _SortRow extends StatelessWidget {
  const _SortRow({required this.mode, required this.selected, required this.onTap});

  final SortMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? context.p.accentSurface : context.p.field,
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.field),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.field),
              border: Border.all(
                color: selected ? AppColors.accent : context.p.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(_icon, size: 19, color: selected ? AppColors.accent : context.p.muted),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mode.label, style: AppText.body(14, weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(mode.hint, style: AppText.body(11.5, color: context.p.mutedLight)),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: selected ? AppColors.accent : context.p.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (mode) {
        SortMode.recommended => Icons.auto_awesome_outlined,
        SortMode.priceAsc => Icons.arrow_upward_rounded,
        SortMode.priceDesc => Icons.arrow_downward_rounded,
        SortMode.rating => Icons.star_outline_rounded,
        SortMode.popular => Icons.local_fire_department_outlined,
        SortMode.newest => Icons.fiber_new_outlined,
      };
}
