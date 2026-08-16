// Shared test plumbing.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Inter/Poppins faces into the test binding.
///
/// Widget tests otherwise measure text with a fixed-width fallback font, which
/// inflates every width and reports overflows that do not exist on a device —
/// seven phantom ones, the first time this suite ran without it.
Future<void> loadAppFonts() async {
  const families = {
    'Inter': ['400', '500', '600', '700'],
    'Poppins': ['500', '600', '700'],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final weight in entry.value) {
      final bytes = File('assets/fonts/${entry.key}-$weight.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}
