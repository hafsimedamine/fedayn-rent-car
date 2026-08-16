// Car card shared by the Home and Saved tabs.
// Photo | details | heart, on a white 16px-radius card with a soft shadow.

import 'package:flutter/material.dart';

import '../data/fleet.dart';
import '../data/models.dart';
import '../theme.dart';
import 'common.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    required this.isFav,
    required this.onToggleFav,
    required this.onTap,
  });

  final Car car;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;

  static (Color, String) availability(BuildContext context, Car car) => switch (car.avail) {
        Availability.now => (AppColors.green, 'Disponible'),
        Availability.soon => (AppColors.accent, 'Disponible dès le ${car.availDate}'),
        Availability.rented => (context.p.grayDot, 'En location'),
      };

  @override
  Widget build(BuildContext context) {
    final (dot, availLabel) = availability(context, car);
    // The card is laid out against the width it actually gets, not the screen:
    // 316px is what a 360px phone leaves after the list's 22px side padding.
    final compact = MediaQuery.sizeOf(context).width < 370;

    return Material(
      color: context.p.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          // 2px off each side on a narrow phone. Together with the smaller
          // thumbnail this is what gets "Disponible" (needs 60.5px) and the
          // spec line (160.8px) their full text instead of an ellipsis.
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: context.p.cardBorder),
            boxShadow: [
              BoxShadow(color: context.p.navy.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          // Clip.none: the heart is deliberately positioned 2px outside the
          // stack, into the card's own padding. A Stack clips by default, so
          // those 2px were being shaved off the top and right of the button.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Narrower thumbnail on a narrow phone. At 360px wide the
                  // text column got 170px, and both "5 places · Manuelle ·
                  // Essence" (153px behind a 24px heart gutter) and the
                  // availability-plus-price row (176px) had to ellipsise.
                  // Giving back 14px clears both without touching type sizes.
                  CarThumb(car: car, width: compact ? 96 : 110, height: 106),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Only the first two lines sit level with the heart, so
                        // only they give up 24px to it. The spec line clears it
                        // vertically and needs every pixel: at 360px wide it
                        // wanted 160.8 and the gutter left it 158.
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(car.name, style: AppText.body(14.5, weight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text('${catFr(car.cat)} • ${transFr(car.trans)}',
                                  style: AppText.body(11.5, weight: FontWeight.w500, color: context.p.mutedLight)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // scaleDown rather than an ellipsis: the longest spec
                        // string ("4 places · Automatique · Électrique") runs
                        // about 6px past a 360px phone. It renders at full
                        // size everywhere else and gives up a fraction only
                        // where it has to, instead of losing the fuel type.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${car.seats} places · ${transFr(car.trans)} · ${fuelFr(car.fuel)}',
                            maxLines: 1,
                            style: AppText.body(11, color: context.p.muted),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: Color(0xFFE1B23B)),
                            const SizedBox(width: 4),
                            Text(car.rating, style: AppText.body(11.5, weight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Text('(${car.reviews} avis)', style: AppText.body(11, color: context.p.mutedLight)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Wrap, not Row: on a narrow phone a four-figure
                        // price left "Disponible" 53px of the 60.5px it needs,
                        // and shaving font sizes to buy those 7px just moved
                        // the problem to the next longest string. This keeps
                        // both at full size and drops the price to its own
                        // line only when they genuinely do not fit.
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            AvailabilityDot(color: dot, label: availLabel),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${fmtMad(car.price)} MAD',
                                    style: AppText.heading(17, color: AppColors.accent, weight: FontWeight.w700)),
                                const SizedBox(width: 2),
                                Text('/jour',
                                    style: AppText.body(11, weight: FontWeight.w500, color: context.p.mutedLight)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(top: -2, right: -2, child: HeartButton(isFav: isFav, onTap: onToggleFav)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded car photo with the grey car-icon placeholder behind it, so a missing
/// or still-loading image degrades to the design's placeholder rather than a gap.
class CarThumb extends StatelessWidget {
  const CarThumb({super.key, required this.car, this.width = 110, this.height = 106, this.radius = 12});

  final Car car;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // Decode at the size actually drawn. The source photos are ~800px wide;
    // without this every 110px thumbnail holds a full-size bitmap in memory.
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CarPlaceholder(name: car.name),
              Image.asset(
                car.photoAsset,
                fit: BoxFit.cover,
                cacheWidth: (width * dpr).round(),
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grey box + car icon + name, the design's intentional image placeholder.
class CarPlaceholder extends StatelessWidget {
  const CarPlaceholder({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Container(
        color: context.p.cardBorder,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_filled_outlined, size: 26, color: context.p.mutedLight),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(9, weight: FontWeight.w600, color: context.p.labelIdle),
              ),
            ),
          ],
        ),
      );
}

/// Identifies the heart's own ScaleTransition; the surrounding Material and
/// InkWell contribute their own, so tests need to target this one.
const heartScaleKey = ValueKey('heart-scale');

/// Circular heart toggle; fills with accent and pops on activation.
class HeartButton extends StatefulWidget {
  const HeartButton({super.key, required this.isFav, required this.onTap, this.size = 34});

  final bool isFav;
  final VoidCallback onTap;
  final double size;

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> with SingleTickerProviderStateMixin {
  // Built in initState, not as a lazy `late final`: a card disposed before it
  // ever painted (scrolled out of a list) would otherwise run the initialiser
  // from dispose(), by which point the element is deactivated and the ticker
  // lookup throws.
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.3), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    // Seed to the end of the pop. A card that is already favourited when first
    // built never animates, and would otherwise sit at the tween's start value
    // — a visibly undersized heart until it was toggled.
    if (widget.isFav) _c.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant HeartButton old) {
    super.didUpdateWidget(old);
    // Pop only on the empty -> filled transition, as in the prototype.
    if (widget.isFav && !old.isFav) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.p.surface.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: context.p.navy.withValues(alpha: 0.14),
      child: InkWell(
        onTap: widget.onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: ScaleTransition(
              key: heartScaleKey,
              scale: widget.isFav ? _scale : const AlwaysStoppedAnimation(1.0),
              child: Icon(
                widget.isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 17,
                color: widget.isFav ? AppColors.accent : context.p.mutedLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
