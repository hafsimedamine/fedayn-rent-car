// Booking step 4 — full-screen processing, then success or a declined error.

import 'dart:async';

import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'book_confirm.dart';

class BookProcessingScreen extends StatefulWidget {
  const BookProcessingScreen({super.key});

  @override
  State<BookProcessingScreen> createState() => _BookProcessingScreenState();
}

class _BookProcessingScreenState extends State<BookProcessingScreen> {
  bool _declined = false;
  bool _declinedOnce = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _run();
  }

  void _run() {
    setState(() => _declined = false);
    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      final shouldDecline = AppScope.read(context).paymentDeclinesFirstAttempt && !_declinedOnce;
      if (shouldDecline) {
        _declinedOnce = true;
        setState(() => _declined = true);
      } else {
        _confirmer();
      }
    });
  }

  /// Le paiement accepté, la réservation est enregistrée avant d'afficher la
  /// confirmation — sinon l'écran annoncerait une réservation qui n'existe
  /// nulle part.
  Future<void> _confirmer() async {
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    try {
      await app.confirmerReservation();
    } on StateError {
      // Aucune période choisie : ne devrait pas arriver, l'écran des dates
      // verrouille le passage au paiement. On n'invente pas de réservation.
      if (!mounted) return;
      navigator.pop();
      return;
    }
    if (!mounted) return;
    navigator.pushReplacement(MaterialPageRoute(builder: (_) => const BookConfirmScreen()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: _declined ? _declinedView() : _processingView(),
          ),
        ),
      ),
    );
  }

  Widget _processingView() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(context.p.accent)),
          ),
          const SizedBox(height: 22),
          Text('Traitement de votre paiement…', textAlign: TextAlign.center, style: AppText.heading(18)),
          const SizedBox(height: 8),
          Text('Ne fermez pas cette page.', style: AppText.body(13, color: context.p.muted)),
        ],
      );

  Widget _declinedView() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: context.p.redSurface, shape: BoxShape.circle),
            child: Icon(Icons.close_rounded, size: 34, color: context.p.red),
          ),
          const SizedBox(height: 22),
          Text('Paiement refusé', textAlign: TextAlign.center, style: AppText.heading(22)),
          const SizedBox(height: 10),
          Text(
            'Paiement refusé. Veuillez essayer une autre carte.',
            textAlign: TextAlign.center,
            style: AppText.body(14, color: context.p.muted, height: 1.55),
          ),
          const SizedBox(height: 26),
          PrimaryButton(label: 'Réessayer', onPressed: _run),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Changer de carte',
            height: 54,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      );
}
