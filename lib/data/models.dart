// Domain models for the Fedayn's Rent Car app.

import 'dart:typed_data';

enum Availability { now, soon, rented }

class Car {
  const Car({
    required this.id,
    required this.name,
    required this.cat,
    required this.trans,
    required this.fuel,
    required this.seats,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.avail,
    required this.filters,
    required this.photo,
    this.availDate,
  });

  final String id;
  final String name;
  final String cat;
  final String trans;
  final String fuel;
  final int seats;
  final int price; // MAD per day
  final String rating;
  final int reviews;
  final Availability avail;
  final String? availDate;
  final List<String> filters;

  /// Basename of the photo in assets/images/cars/.
  final String photo;

  bool get isElectric => fuel == 'Electric';

  String get photoAsset => 'assets/images/cars/$photo.jpg';
}

class CarSpec {
  const CarSpec({
    required this.reg,
    required this.years,
    required this.km,
    required this.plate,
    required this.color,
    required this.doors,
    this.tank,
    this.range,
    this.battery,
  });

  final String reg;
  final int years;
  final String km;
  final String plate;
  final String color;
  final int doors;
  final String? tank;
  final String? range;
  final String? battery;
}

class Agency {
  const Agency({
    required this.name,
    required this.addr,
    required this.short,
    required this.hours,
    required this.tel,
    required this.email,
  });

  final String name;
  final String addr;
  final String short;
  final String hours;
  final String tel;
  final String email;
}

enum BookingKind { upcoming, active, past }

class Booking {
  const Booking({
    required this.ref,
    required this.name,
    required this.cat,
    required this.range,
    required this.days,
    required this.loc,
    required this.total,
    required this.kind,
    this.hint,
    this.pickTime,
    this.retTime,
  });

  final String ref;
  final String name;
  final String cat;
  final String range;
  final String days;
  final String loc;
  final String total;
  final BookingKind kind;
  final String? hint;
  final String? pickTime;
  final String? retTime;
}

class SavedCard {
  const SavedCard({required this.id, required this.brand, required this.last, required this.exp, required this.isDefault});

  final String id;
  final String brand;
  final String last;
  final String exp;
  final bool isDefault;
}

/// Where a document — or the account as a whole — stands.
///
/// [missing] is the honest starting point: nothing has been supplied yet, so
/// there is nothing to have approved. It is distinct from [rejected], which
/// means a document arrived and was turned down.
enum VerifyState { missing, pending, verified, rejected }

/// A document photo the user actually took or picked.
class CapturedPhoto {
  const CapturedPhoto({required this.path, required this.bytes});

  final String path;

  /// Populated on web, where there is no readable file path.
  final Uint8List? bytes;

  String get fileName => path.split(RegExp(r'[/\\]')).last;
}
