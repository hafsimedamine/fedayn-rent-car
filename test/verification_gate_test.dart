// Skipping verification is allowed, but it must actually lock renting — and
// the app has to keep saying so.

import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/models.dart';
import 'package:fedayns_rent_car/state/app_state.dart';

void main() {
  test('a fresh account cannot rent', () {
    final s = AppState();
    expect(s.documentsComplete, isFalse);
    expect(s.canRent, isFalse);
  });

  test('one document is not enough', () {
    final s = AppState()..markCinUploaded();
    expect(s.documentsComplete, isFalse);
    expect(s.canRent, isFalse);
    expect(s.missingDocumentsLabel, 'votre permis de conduire');

    final t = AppState()..markLicenseUploaded();
    expect(t.canRent, isFalse);
    expect(t.missingDocumentsLabel, 'votre CIN');
  });

  test('both documents plus an approved review unlocks renting', () {
    final s = AppState()
      ..markCinUploaded()
      ..markLicenseUploaded();

    expect(s.documentsComplete, isTrue);
    expect(s.missingDocumentsLabel, isEmpty);
    expect(s.canRent, isTrue);
  });

  test('documents alone do not unlock renting while review is pending', () {
    final s = AppState()
      ..reviewOutcome = VerifyState.pending
      ..markCinUploaded()
      ..markLicenseUploaded();

    expect(s.documentsComplete, isTrue);
    expect(s.canRent, isFalse, reason: 'still awaiting review');
  });

  test('an account with no documents is never reported as verified', () {
    final s = AppState();
    expect(s.verifyState, VerifyState.missing);
    expect(s.cinStatus, VerifyState.missing);
    expect(s.licenseStatus, VerifyState.missing);
    expect(s.isVerified, isFalse);
  });

  test('a document keeps its own status until it is supplied', () {
    final s = AppState()..markCinUploaded();
    expect(s.cinStatus, VerifyState.verified);
    expect(s.licenseStatus, VerifyState.missing, reason: 'never sent, so never approved');
    expect(s.verifyState, VerifyState.missing, reason: 'the account is only as good as its weakest document');
  });

  test('the review toggle cannot approve documents that do not exist', () {
    final s = AppState()..reviewOutcome = VerifyState.verified;
    expect(s.verifyState, VerifyState.missing);
    expect(s.canRent, isFalse);
  });

  test('removing a document takes the account back out of verified', () {
    final s = AppState()
      ..markCinUploaded()
      ..markLicenseUploaded();
    expect(s.canRent, isTrue);

    s.clearCin();
    expect(s.cinStatus, VerifyState.missing);
    expect(s.canRent, isFalse);
    expect(s.missingDocumentsLabel, 'votre CIN');
  });

  test('logging out drops the stored photos, not just the flags', () {
    final s = AppState()
      ..markCinUploaded(photo: const CapturedPhoto(path: '/tmp/cin.jpg', bytes: null))
      ..markLicenseUploaded(photo: const CapturedPhoto(path: '/tmp/permis.jpg', bytes: null));
    expect(s.cinPhoto, isNotNull);

    s.logOut();
    expect(s.cinPhoto, isNull);
    expect(s.licensePhoto, isNull);
  });

  test('logging out clears uploaded documents', () {
    final s = AppState()
      ..markCinUploaded()
      ..markLicenseUploaded();
    expect(s.canRent, isTrue);

    s.logOut();
    expect(s.documentsComplete, isFalse);
    expect(s.canRent, isFalse, reason: 'the next user must not inherit them');
  });
}
