// Blocking loading indicator for work the user has to wait on.
//
// Signing in derives a PBKDF2 key on a background isolate, which takes on the
// order of a second. Without this the screen simply sits there and reads as a
// freeze, so anything that can take a perceptible moment goes through
// [runWithLoading].

import 'package:flutter/material.dart';

import '../theme.dart';

/// Runs [action] behind a blocking spinner and returns its result.
///
/// The spinner is guaranteed to be on screen *before* [action] starts: the
/// dialog route only paints on the following frame, and starting a second of
/// key derivation in the same turn meant the user saw the old screen sit
/// there — exactly the freeze this is supposed to explain.
///
/// The overlay is removed on every path — success, failure, or the caller
/// being disposed mid-flight — so it can never strand the UI.
Future<T> runWithLoading<T>(
  BuildContext context,
  Future<T> Function() action, {
  String? message,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  // An explicit route rather than showDialog(): dismissal then removes *this*
  // route by identity, instead of popping whatever happens to be on top.
  final route = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => LoadingBarrier(message: message),
  );

  void dismiss() {
    if (route.isActive) navigator.removeRoute(route);
  }

  navigator.push(route);

  try {
    // Wait for the frame that draws the barrier. ensureVisualUpdate guards the
    // case where nothing else has scheduled one, so this can never hang.
    final binding = WidgetsBinding.instance;
    binding.ensureVisualUpdate();
    await binding.endOfFrame;

    return await action();
  } finally {
    dismiss();
  }
}

/// The dialog body: a card with a spinner, and the back button disabled so the
/// barrier cannot be escaped while work is in flight.
class LoadingBarrier extends StatelessWidget {
  const LoadingBarrier({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // Material, not a decorated Container: a DialogRoute inserts no Material
      // of its own, and a Text without one paints in the framework's red
      // "missing style" debug colours.
      child: Center(
        child: Material(
          color: context.p.surface,
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child:
                      CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(context.p.accent)),
                ),
                if (message != null) ...[
                  const SizedBox(height: 18),
                  Text(message!, textAlign: TextAlign.center, style: AppText.body(14, weight: FontWeight.w500)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
