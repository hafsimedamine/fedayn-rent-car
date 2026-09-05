// Fleet, agency and booking data ported verbatim from the design prototype's
// CARS / SPECS / AGENCIES / UPCOMING / ACTIVE / PAST statics.

import 'calendar.dart';
import 'models.dart';

const kBrand = "Fedayn's Rent Car";

const kCars = <Car>[
  Car(id: 'c_sandero', name: 'Dacia Sandero', cat: 'Economy', trans: 'Manual', fuel: 'Petrol', seats: 5, price: 250, rating: '4.6', reviews: 89, avail: Availability.now, filters: ['Economy'], photo: 'dacia_sandero'),
  Car(id: 'c_clio', name: 'Renault Clio', cat: 'Citadine', trans: 'Manual', fuel: 'Petrol', seats: 5, price: 280, rating: '4.7', reviews: 142, avail: Availability.now, filters: ['Citadine'], photo: 'renault_clio'),
  Car(id: 'c_duster', name: 'Dacia Duster', cat: 'SUV', trans: 'Manual', fuel: 'Diesel', seats: 5, price: 450, rating: '4.8', reviews: 210, avail: Availability.now, filters: ['SUV'], photo: 'dacia_duster'),
  Car(id: 'c_golf', name: 'Volkswagen Golf', cat: 'Compact', trans: 'Automatic', fuel: 'Petrol', seats: 5, price: 400, rating: '4.7', reviews: 96, avail: Availability.now, filters: ['Sedan', 'Automatic'], photo: 'volkswagen_golf'),
  Car(id: 'c_208', name: 'Peugeot 208', cat: 'Citadine', trans: 'Manual', fuel: 'Petrol', seats: 5, price: 300, rating: '4.5', reviews: 74, avail: Availability.soon, availDate: '16 juil.', filters: ['Citadine'], photo: 'peugeot_208'),
  Car(id: 'c_tucson', name: 'Hyundai Tucson', cat: 'SUV', trans: 'Automatic', fuel: 'Diesel', seats: 5, price: 600, rating: '4.9', reviews: 133, avail: Availability.soon, availDate: '18 juil.', filters: ['SUV', 'Automatic'], photo: 'hyundai_tucson'),
  Car(id: 'c_merc', name: 'Mercedes C-Class', cat: 'Luxury', trans: 'Automatic', fuel: 'Petrol', seats: 5, price: 1200, rating: '4.9', reviews: 58, avail: Availability.now, filters: ['Luxury', 'Automatic'], photo: 'mercedes_c_class'),
  Car(id: 'c_spring', name: 'Dacia Spring', cat: 'Electric', trans: 'Automatic', fuel: 'Electric', seats: 4, price: 350, rating: '4.4', reviews: 61, avail: Availability.now, filters: ['Electric', 'Automatic'], photo: 'dacia_spring'),
  Car(id: 'c_tesla', name: 'Tesla Model 3', cat: 'Electric', trans: 'Automatic', fuel: 'Electric', seats: 5, price: 1500, rating: '4.9', reviews: 88, avail: Availability.soon, availDate: '20 juil.', filters: ['Electric', 'Automatic'], photo: 'tesla_model_3'),
  Car(id: 'c_evoque', name: 'Range Rover Evoque', cat: 'Luxury SUV', trans: 'Automatic', fuel: 'Diesel', seats: 5, price: 1800, rating: '4.8', reviews: 42, avail: Availability.rented, filters: ['Luxury', 'SUV', 'Automatic'], photo: 'range_rover_evoque'),
  Car(id: 'c_500', name: 'Fiat 500', cat: 'Citadine', trans: 'Manual', fuel: 'Petrol', seats: 4, price: 270, rating: '4.5', reviews: 103, avail: Availability.rented, filters: ['Citadine'], photo: 'fiat_500'),
];

Car carById(String id) => kCars.firstWhere((c) => c.id == id, orElse: () => kCars.first);
Car carByName(String name) => kCars.firstWhere((c) => c.name == name, orElse: () => kCars.first);

const kFilterChips = ['All', 'Citadine', 'Economy', 'Sedan', 'SUV', 'Luxury', 'Electric', 'Automatic'];

const kSpecs = <String, CarSpec>{
  'c_sandero': CarSpec(reg: '9 février 2022', years: 3, km: '52 400', plate: '38921-A-6', color: 'Blanc glacier', tank: '50 litres', doors: 5),
  'c_clio': CarSpec(reg: '21 juin 2022', years: 3, km: '41 780', plate: '11045-B-1', color: 'Gris platine', tank: '42 litres', doors: 5),
  'c_duster': CarSpec(reg: '14 mars 2022', years: 3, km: '48 250', plate: '12345-A-6', color: 'Gris argent', tank: '50 litres', doors: 5),
  'c_golf': CarSpec(reg: '3 septembre 2023', years: 2, km: '29 600', plate: '77210-C-1', color: 'Blanc pur', tank: '50 litres', doors: 5),
  'c_208': CarSpec(reg: '18 mai 2023', years: 2, km: '22 150', plate: '55302-A-6', color: 'Bleu Vertigo', tank: '44 litres', doors: 5),
  'c_tucson': CarSpec(reg: '2 avril 2023', years: 2, km: '31 900', plate: '64118-B-1', color: 'Gris titane', tank: '54 litres', doors: 5),
  'c_merc': CarSpec(reg: '11 janvier 2023', years: 3, km: '26 300', plate: '90876-A-6', color: 'Noir obsidienne', tank: '66 litres', doors: 5),
  'c_spring': CarSpec(reg: '7 juillet 2023', years: 2, km: '18 420', plate: '40233-D-1', color: 'Gris béton', range: '230 km (WLTP)', battery: '26,8 kWh', doors: 5),
  'c_tesla': CarSpec(reg: '29 mars 2023', years: 2, km: '24 870', plate: '81190-A-6', color: 'Blanc nacré', range: '510 km (WLTP)', battery: '60 kWh', doors: 4),
  'c_evoque': CarSpec(reg: '5 décembre 2022', years: 3, km: '37 500', plate: '20654-C-1', color: 'Gris Corris', tank: '65 litres', doors: 5),
  'c_500': CarSpec(reg: '16 août 2021', years: 4, km: '58 900', plate: '30712-B-6', color: 'Rouge Passione', tank: '35 litres', doors: 3),
};

const kEquipment = [
  'Climatisation', 'GPS', 'Bluetooth', 'Caméra de recul',
  'Régulateur de vitesse', 'Capteurs de stationnement', 'USB / USB-C', 'Airbags',
];

const kAgencies = <String, Agency>{
  'maarif': Agency(name: 'Casablanca - Maarif', addr: '42, Rue Ibnou Mounir, Maarif, Casablanca', short: '42 Rue Ibnou Mounir', hours: 'Lun–Sam : 08h00 – 20h00 · Dim : 09h00 – 14h00', tel: '+212 522 25 40 18', email: 'maarif@fedaynrentcar.ma'),
  'aeroport': Agency(name: 'Casablanca - Aéroport Mohammed V', addr: 'Terminal 1, Zone Arrivées, Aéroport Mohammed V, Nouaceur', short: 'Terminal 1, Zone Arrivées', hours: 'Tous les jours : 06h00 – 23h00', tel: '+212 522 53 91 44', email: 'aeroport@fedaynrentcar.ma'),
  'agdal': Agency(name: 'Rabat - Agdal', addr: '18, Avenue de France, Agdal, Rabat', short: '18 Avenue de France', hours: 'Lun–Sam : 08h30 – 19h30 · Dim : fermé', tel: '+212 537 67 22 09', email: 'agdal@fedaynrentcar.ma'),
};

// Il n'y a plus de réservations d'exemple. kUpcoming/kActive/kPast affichaient
// à tout nouvel utilisateur un Dacia Duster « à venir », une Golf « en cours »
// et deux locations passées qu'il n'avait jamais faites. Les réservations
// viennent maintenant de AppState, alimenté par le dépôt.

// Le calendrier n'a plus de constantes : les jours indisponibles viennent de
// l'état réel de la voiture (voir AppState.joursIndisponibles) et « aujourd'hui »
// de DateTime.now(). kBookedDays/kToday figeaient tout sur juillet 2026.
const kTimes = ['08:00', '09:00', '10:00', '11:00', '12:00', '14:00', '16:00', '18:00'];
const kLocations = ['Casablanca — Maarif', 'Casablanca — Airport', 'Rabat — Agdal'];
const kIncluded = [
  'Assurance tous risques incluse',
  'Véhicule géolocalisé (GPS)',
  'Assistance routière 24/7',
  'Conducteur supplémentaire — gratuit',
  'Kilométrage illimité',
];

const kMonths = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
const kYears = ['2026', '2027', '2028', '2029', '2030', '2031', '2032', '2033', '2034', '2035', '2036'];

const kLicenseCountries = ['Maroc', 'France', 'Espagne', 'Allemagne', 'Autre'];
const kLicenseCategories = ['A', 'B', 'C', 'D', 'EB'];

// ── Demo fixtures ───────────────────────────────────────────────────────────
// This build has no backend: the signed-in user, the documents a "scan"
// returns and the saved cards are all fixtures. They are deliberately
// synthetic — example.com is reserved for documentation by RFC 2606, and the
// document numbers are well-formed but invented. Swap these for real data
// when an API is wired up.

const kUserName = 'Test User';
const kUserFirstName = 'User';
const kUserEmail = 'user@example.com';
const kUserPhone = '+212 600 000 000';

/// Account seeded into a brand-new database so the app can be opened and
/// signed into without registering first.
// ── Support contact, shown on Compte › Nous contacter ──
const kSupportPhone = '+212 707-534357';
/// Placeholder address — swap for the real support inbox before release.
/// Kept short enough to sit on one line in the contact card on a 360px phone;
/// 'contact@fedaynsrentcar.ma' wrapped mid-domain there.
const kSupportEmail = 'contact@fedayns.ma';

/// Shown in the Compte footer. Kept in step with pubspec's `version`.
const kAppVersion = '0.1.1';

const kSeedEmail = 'moncef@gmail.com';
const kSeedFullName = 'Mohamed Moncef';
const kSeedPhone = '06555555';
const kSeedPassword = '12345678';

/// What a successful CIN scan/upload fills in. The name is taken from
/// [kUserName] so the ID and the profile cannot drift apart.
const kDemoCinNumber = 'TU 123456';
const kDemoCinName = kUserName;
const kDemoCinBirthDate = '01/01/1990';
const kDemoCinExpiry = '01/01/2032';

/// What a successful driving-licence scan/upload fills in.
const kDemoLicenseNumber = '19/123456';
const kDemoLicenseIssue = '15/06/2015';
const kDemoLicenseExpiry = '15/06/2035';

/// French display helpers — the CARS data keeps English keys internally.
String catFr(String cat) => const {
      'Economy': 'Économique',
      'Citadine': 'Citadine',
      'Sedan': 'Berline',
      'Compact': 'Compacte',
      'SUV': 'SUV',
      'Luxury': 'Luxe',
      'Luxury SUV': 'SUV de luxe',
      'Electric': 'Électrique',
    }[cat] ??
    cat;

String transFr(String t) => t == 'Automatic' ? 'Automatique' : 'Manuelle';

String fuelFr(String f) => switch (f) {
      'Electric' => 'Électrique',
      'Diesel' => 'Diesel',
      _ => 'Essence',
    };

String chipFr(String chip) => const {
      'All': 'Toutes',
      'Citadine': 'Citadine',
      'Economy': 'Économique',
      'Sedan': 'Berline',
      'SUV': 'SUV',
      'Luxury': 'Luxe',
      'Electric': 'Électrique',
      'Automatic': 'Automatique',
    }[chip] ??
    chip;

/// French number grouping — 1850 -> "1 850", using a non-breaking space
/// (U+00A0); the bundled Inter/Poppins have no U+202F glyph.
String fmtMad(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Libellés d'une réservation.
///
/// Vit ici et non sur [Booking] : le modèle ne connaît qu'un identifiant de
/// voiture, et c'est la flotte qui sait à quoi il correspond. Le prototype
/// stockait ces chaînes dans la réservation elle-même, ce qui interdisait d'en
/// recalculer quoi que ce soit.
extension BookingDisplay on Booking {
  Car get car => carById(carId);
  String get name => car.name;
  String get cat => catFr(car.cat);
  String get loc => pickLoc;

  BookingKind get kind => kindAt(DateTime.now());

  /// « 14 – 18 juil. »
  String get range => formatPeriode(startDate, endDate);

  /// « 4 jours »
  String get days => formatDuree(nuitsEntre(startDate, endDate));

  /// « 1 850 MAD »
  String get total => '${fmtMad(totalPrice)} MAD';

  /// Phrase de contexte sous la carte, selon l'onglet où elle apparaît.
  String? get hint {
    final now = DateTime.now();
    switch (kindAt(now)) {
      case BookingKind.upcoming:
        final jours = nuitsEntre(jourSeul(now), startDate);
        if (jours <= 0) return 'Prise en charge aujourd\'hui';
        if (jours == 1) return 'Prise en charge demain';
        return 'Prise en charge dans $jours jours';
      case BookingKind.active:
        final restants = nuitsEntre(jourSeul(now), endDate);
        if (restants <= 0) return 'Retour aujourd\'hui';
        if (restants == 1) return 'Retour demain';
        return 'Retour dans $restants jours';
      case BookingKind.past:
        return null;
    }
  }
}
