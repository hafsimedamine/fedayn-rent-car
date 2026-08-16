import 'package:flutter/material.dart';

import '../../data/fleet.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/car_card.dart';
import '../../widgets/common.dart';
import '../booking_details.dart';
import '../main_shell.dart';
import '../modals.dart';

class RentalsTab extends StatefulWidget {
  const RentalsTab({super.key});

  @override
  State<RentalsTab> createState() => _RentalsTabState();
}

class _RentalsTabState extends State<RentalsTab> {
  BookingKind _seg = BookingKind.upcoming;

  /// Refs whose removal animation has finished. Cancelling only marks a
  /// booking cancelled; the card stays in the list long enough to fade and
  /// collapse, and lands here once it has.
  final Set<String> _removed = {};

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    final source = switch (_seg) {
      BookingKind.upcoming => app.rentalsEmpty ? const <Booking>[] : kUpcoming,
      BookingKind.active => kActive,
      BookingKind.past => kPast,
    };
    final bookings = [
      for (final b in source)
        if (!_removed.contains(b.ref)) b,
    ];

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Mes locations', style: AppText.heading(22)),
            const SizedBox(height: 16),
            _Segmented(
              value: _seg,
              onChanged: (v) => setState(() => _seg = v),
            ),
            Expanded(
              child: bookings.isEmpty
                  ? _EmptyState(onBrowse: () => MainShell.of(context).goToTab(0))
                  // Not ListView.separated: the gap has to collapse with
                  // the card it belongs to, so it lives inside the item.
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 18, bottom: 12),
                      itemCount: bookings.length,
                      itemBuilder: (_, i) {
                        final booking = bookings[i];
                        return _CollapsingItem(
                          key: ValueKey(booking.ref),
                          visible: !app.isCancelled(booking.ref),
                          onGone: () => setState(() => _removed.add(booking.ref)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BookingCard(booking: booking),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades and collapses its child away when [visible] turns false, then calls
/// [onGone] so the owner can drop it from the list for good.
class _CollapsingItem extends StatefulWidget {
  const _CollapsingItem({
    super.key,
    required this.visible,
    required this.onGone,
    required this.child,
  });

  final bool visible;
  final VoidCallback onGone;
  final Widget child;

  @override
  State<_CollapsingItem> createState() => _CollapsingItemState();
}

class _CollapsingItemState extends State<_CollapsingItem> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: widget.visible ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant _CollapsingItem old) {
    super.didUpdateWidget(old);
    if (old.visible && !widget.visible) {
      // A plain .then is safe here: a TickerFuture that gets cancelled (the
      // controller being disposed mid-flight) simply never completes.
      _c.reverse().then((_) {
        if (mounted) widget.onGone();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizeTransition(
        sizeFactor: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
        alignment: Alignment.topCenter,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
          child: widget.child,
        ),
      );
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.value, required this.onChanged});

  final BookingKind value;
  final ValueChanged<BookingKind> onChanged;

  static const _labels = {
    BookingKind.upcoming: 'À venir',
    BookingKind.active: 'En cours',
    BookingKind.past: 'Passées',
  };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: context.p.chipBg, borderRadius: BorderRadius.circular(AppRadius.small)),
        child: Row(
          children: [
            for (final k in BookingKind.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(k),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: k == value ? context.p.elevated : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: k == value
                          ? [BoxShadow(color: context.p.navy.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 1))]
                          : null,
                    ),
                    child: Text(
                      _labels[k]!,
                      style: AppText.body(13,
                          weight: FontWeight.w600, color: k == value ? context.p.navy : context.p.muted),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final car = carByName(booking.name);
    final reviewed = app.reviews.containsKey(booking.ref);

    final (badgeLabel, badgeBg, badgeFg) = switch (booking.kind) {
      BookingKind.upcoming => ('Confirmée', context.p.greenSurface, AppColors.green),
      BookingKind.active => ('En cours', context.p.greenSurface, AppColors.green),
      BookingKind.past => ('Terminée', context.p.chipBg, context.p.muted),
    };

    return Material(
      color: context.p.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BookingDetailsScreen(booking: booking)),
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: context.p.cardBorder),
            boxShadow: [BoxShadow(color: context.p.navy.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarThumb(car: car, width: 92, height: 78),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('${booking.name} • ${catFr(booking.cat)}',
                                  style: AppText.body(14, weight: FontWeight.w600)),
                            ),
                            StatusPill(label: badgeLabel, background: badgeBg, foreground: badgeFg, fontSize: 10),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('#${booking.ref}',
                            style: AppText.body(11.5, weight: FontWeight.w500, color: context.p.mutedLight)),
                        const SizedBox(height: 4),
                        Text('${booking.range} (${booking.days})', style: AppText.body(12, color: context.p.muted)),
                        const SizedBox(height: 2),
                        Text(booking.loc, style: AppText.body(11.5, color: context.p.mutedLight)),
                        const SizedBox(height: 6),
                        Text(booking.total, style: AppText.heading(15, color: AppColors.accent, weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              if (booking.hint != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: context.p.infoBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(booking.hint!, style: AppText.body(11.5, weight: FontWeight.w500, color: context.p.infoText)),
                ),
              ],
              const SizedBox(height: 12),
              Divider(color: context.p.divider, height: 1),
              const SizedBox(height: 12),
              _actions(context, reviewed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, bool reviewed) {
    switch (booking.kind) {
      case BookingKind.upcoming:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SmallButton(
              label: 'Voir les détails',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BookingDetailsScreen(booking: booking)),
              ),
            ),
            _SmallButton(
              label: 'Annuler',
              danger: true,
              onTap: () => showCancelBookingSheet(context, booking.ref),
            ),
          ],
        );
      case BookingKind.active:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SmallButton(label: 'Localiser la voiture', filled: true, onTap: () => showAppToast(context, 'Localisation…')),
            _SmallButton(label: 'Prolonger', onTap: () => showAppToast(context, 'Prolongation demandée')),
          ],
        );
      case BookingKind.past:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (reviewed)
              Row(
                children: [
                  for (var i = 0; i < 5; i++)
                    Icon(
                      i < (AppScope.of(context).reviews[booking.ref] ?? 0) ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 15,
                      color: const Color(0xFFE1B23B),
                    ),
                ],
              )
            else
              _SmallButton(
                label: '★ Noter cette location',
                onTap: () => showRateRentalSheet(context, booking.ref),
              ),
            _SmallButton(label: 'Réserver à nouveau', filled: true, onTap: () => showAppToast(context, 'Nouvelle réservation')),
          ],
        );
    }
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.onTap, this.filled = false, this.danger = false});

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? context.p.onInverseSurface : (danger ? AppColors.red : context.p.navy);
    final bg = filled ? context.p.inverseSurface : context.p.surface;
    final border = filled ? context.p.inverseSurface : (danger ? context.p.redBorder : context.p.border);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(label, style: AppText.body(12, weight: FontWeight.w600, color: fg)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_note_outlined, size: 60, color: Color(0xFFD5DBE3)),
            const SizedBox(height: 20),
            Text('Aucune location', style: AppText.heading(19)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                'Vos réservations apparaîtront ici une fois une voiture louée.',
                textAlign: TextAlign.center,
                style: AppText.body(13.5, color: context.p.muted, height: 1.55),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
              ),
              child: Text('Parcourir les voitures', style: AppText.body(14, weight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
      );
}
