// Stockage des réservations.
//
// Même forme que AuthRepository : une interface, une implémentation SQLite sur
// l'appareil, une en mémoire pour le web. Brancher un service distant (Supabase
// ou autre) revient à écrire une troisième implémentation et à changer une ligne
// dans main.dart — aucun écran n'a à le savoir.
//
// Les noms de colonnes suivent le schéma demandé : user_id, car_id, start_date,
// end_date, total_price, status.

import '../models.dart';

abstract interface class BookingRepository {
  /// Réservations d'un compte, les plus récentes d'abord.
  Future<List<Booking>> forUser(int userId);

  Future<void> add(Booking booking, {required int userId});

  Future<void> setStatus(String ref, BookingStatus status);
}

/// Repli pour le web, et pour les aperçus sans base.
class InMemoryBookingRepository implements BookingRepository {
  final Map<int, List<Booking>> _parUtilisateur = {};

  @override
  Future<List<Booking>> forUser(int userId) async => List.of(_parUtilisateur[userId] ?? const []);

  @override
  Future<void> add(Booking booking, {required int userId}) async {
    (_parUtilisateur[userId] ??= []).insert(0, booking);
  }

  @override
  Future<void> setStatus(String ref, BookingStatus status) async {
    for (final entry in _parUtilisateur.entries) {
      final i = entry.value.indexWhere((b) => b.ref == ref);
      if (i != -1) entry.value[i] = entry.value[i].copyWith(status: status);
    }
  }
}
