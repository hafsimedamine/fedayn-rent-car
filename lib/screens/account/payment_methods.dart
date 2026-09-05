import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Moyens de paiement', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: app.cards.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.credit_card_off_outlined, size: 52, color: Color(0xFFD5DBE3)),
                          const SizedBox(height: 16),
                          Text('Aucune carte enregistrée', style: AppText.heading(17)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                      itemCount: app.cards.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final card = app.cards[i];
                        return Dismissible(
                          key: ValueKey(card.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: context.p.red,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                            ),
                            child: Icon(Icons.delete_outline_rounded, color: context.p.page),
                          ),
                          onDismissed: (_) {
                            app.removeCard(card.id);
                            showAppToast(context, 'Carte supprimée');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.p.surface,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: context.p.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: context.p.field,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: context.p.border),
                                  ),
                                  child: Text(card.brand, style: AppText.body(10, weight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('•••• ${card.last}', style: AppText.body(14, weight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text('Expire ${card.exp}', style: AppText.body(11.5, color: context.p.mutedLight)),
                                    ],
                                  ),
                                ),
                                if (card.isDefault)
                                  StatusPill(
                                    label: 'Par défaut',
                                    background: context.p.greenSurface,
                                    foreground: context.p.green,
                                    fontSize: 10,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            StickyBar(
              child: PrimaryButton(
                label: 'Ajouter une carte',
                onPressed: () => showAppToast(context, 'Ajout de carte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
