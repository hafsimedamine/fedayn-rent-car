import 'package:flutter/material.dart';

import '../theme.dart';
import 'common.dart';

/// "ou continuer avec" divider + Google / Apple buttons.
/// [stacked] matches Login (full-width, one per row); Register uses the row form.
class SocialSection extends StatelessWidget {
  const SocialSection({super.key, this.stacked = true});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: context.p.border, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('ou continuer avec',
                  style: AppText.body(12, weight: FontWeight.w500, color: context.p.mutedLight)),
            ),
            Expanded(child: Divider(color: context.p.border, height: 1)),
          ],
        ),
        SizedBox(height: stacked ? 20 : 14),
        if (stacked) ...[
          SecondaryButton(label: 'Continuer avec Google', onPressed: () {}),
          const SizedBox(height: 10),
          SecondaryButton(label: 'Continuer avec Apple', onPressed: () {}),
        ] else
          Row(
            children: [
              Expanded(child: SecondaryButton(label: 'Google', onPressed: () {})),
              const SizedBox(width: 10),
              Expanded(child: SecondaryButton(label: 'Apple', onPressed: () {})),
            ],
          ),
      ],
    );
  }
}

/// Bottom "switch to the other auth screen" line.
class AuthSwitchLine extends StatelessWidget {
  const AuthSwitchLine({super.key, required this.prompt, required this.action, required this.onTap});

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
        child: Text.rich(
          TextSpan(
            style: AppText.body(14, weight: FontWeight.w500, color: context.p.muted),
            children: [
              TextSpan(text: '$prompt '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: onTap,
                  child: Text(action, style: AppText.body(14, weight: FontWeight.w600, color: AppColors.accent)),
                ),
              ),
            ],
          ),
        ),
      );
}

/// Small text button used for the password show/hide toggle.
class PwToggle extends StatelessWidget {
  const PwToggle({super.key, required this.obscured, required this.onTap});

  final bool obscured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(obscured ? 'Afficher' : 'Masquer',
              style: AppText.body(12, weight: FontWeight.w600, color: context.p.muted)),
        ),
      );
}
