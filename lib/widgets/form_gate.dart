// Scoped rebuilds for form submit buttons.

import 'package:flutter/material.dart';

/// Rebuilds only its own subtree, and only when [test] flips.
///
/// Every form here used to wire each of its controllers to `setState(() {})`
/// purely so the submit button could re-evaluate whether it was enabled. That
/// rebuilt the entire screen — logo, every field, the social buttons — on each
/// keystroke: ~183 widgets per character on Login, ~255 on Register. This
/// listens to the same controllers but rebuilds the button alone, and stays
/// still while the answer is unchanged, which it is for all but one keystroke.
class FormGate extends StatefulWidget {
  const FormGate({
    super.key,
    required this.listenTo,
    required this.test,
    required this.builder,
  });

  /// Usually the form's [TextEditingController]s.
  final List<Listenable> listenTo;

  /// Evaluated on every change; may also read parent state such as a "busy"
  /// or "terms accepted" flag, which is why it is re-run on rebuild too.
  final bool Function() test;

  final Widget Function(BuildContext context, bool enabled) builder;

  @override
  State<FormGate> createState() => _FormGateState();
}

class _FormGateState extends State<FormGate> {
  late bool _enabled = widget.test();

  @override
  void initState() {
    super.initState();
    _subscribe(widget.listenTo);
  }

  @override
  void didUpdateWidget(covariant FormGate old) {
    super.didUpdateWidget(old);
    if (!identical(old.listenTo, widget.listenTo)) {
      _unsubscribe(old.listenTo);
      _subscribe(widget.listenTo);
    }
    // The parent is rebuilding anyway, so take the new answer without asking
    // for another frame — `test` may close over state that just changed.
    _enabled = widget.test();
  }

  @override
  void dispose() {
    _unsubscribe(widget.listenTo);
    super.dispose();
  }

  void _subscribe(List<Listenable> ls) {
    for (final l in ls) {
      l.addListener(_recheck);
    }
  }

  void _unsubscribe(List<Listenable> ls) {
    for (final l in ls) {
      l.removeListener(_recheck);
    }
  }

  void _recheck() {
    final next = widget.test();
    if (next != _enabled) setState(() => _enabled = next);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _enabled);
}
