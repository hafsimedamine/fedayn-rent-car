// The account-creation journey. Register used to lead to a blank screen because
// the CIN step threw during layout, so this walks the real path.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:fedayns_rent_car/main.dart';
import 'package:fedayns_rent_car/state/app_state.dart';

Future<void> _loadFonts() async {
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

/// Stands in for the OS picker: the plugin cannot run in a widget test, so
/// this returns a small in-memory JPEG as though the user had chosen one.
class _FakeImagePicker extends ImagePickerPlatform {
  _FakeImagePicker({required this.fileName});

  final String fileName;
  ImageSource? lastSource;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    lastSource = source;
    return XFile.fromData(
      Uint8List.fromList(List<int>.filled(64, 0)),
      name: fileName,
      mimeType: 'image/jpeg',
      path: fileName,
    );
  }
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('welcome -> register -> CIN upload -> licence upload', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final picker = _FakeImagePicker(fileName: 'cin.jpg');
    ImagePickerPlatform.instance = picker;

    await tester.pumpWidget(FedaynsApp(state: AppState()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    expect(find.text('Créer votre compte'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(2), '0612345678');
    await tester.enterText(find.byType(TextField).at(3), 'motdepasse1');
    await tester.pump();

    // Accept the terms, which gates the submit button.
    await tester.tap(find.textContaining("J'accepte les"));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Créer un compte'));
    await tester.pumpAndSettle();

    // Step 2 must actually render — this is what was blank.
    expect(tester.takeException(), isNull);
    expect(find.text('Vérifier votre identité'), findsOneWidget);
    expect(find.text('Prendre une photo'), findsOneWidget);
    expect(find.text('Importer une photo'), findsOneWidget);
    expect(find.text('Numéro de CIN'), findsOneWidget);

    // Continue is gated until a document is captured.
    final continueBtn = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuer'),
    );
    expect(continueBtn.onPressed, isNull, reason: 'Continuer should be disabled before capture');

    // Upload fills the fields and unlocks the step.
    await tester.tap(find.text('Importer une photo'));
    await tester.pumpAndSettle();
    expect(picker.lastSource, ImageSource.gallery, reason: 'gallery card must open the gallery');
    expect(find.text('cin.jpg'), findsOneWidget, reason: 'the chosen file should be listed');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuer'));
    await tester.pumpAndSettle();

    // Step 3: the driving licence.
    expect(tester.takeException(), isNull);
    expect(find.text('Ajouter votre permis de conduire'), findsOneWidget);
    expect(find.text('Prendre une photo'), findsOneWidget);
    expect(find.text('Numéro de permis'), findsOneWidget);
  });
}
