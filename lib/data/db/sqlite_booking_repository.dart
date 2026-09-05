import 'package:sqflite/sqflite.dart';

import '../models.dart';
import 'app_database.dart';
import 'booking_repository.dart';

class SqliteBookingRepository implements BookingRepository {
  SqliteBookingRepository({Database? db}) : _injected = db;

  final Database? _injected;

  Future<Database> get _db async => _injected ?? await AppDatabase.open();

  @override
  Future<List<Booking>> forUser(int userId) async {
    final db = await _db;
    final rows = await db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> add(Booking b, {required int userId}) async {
    final db = await _db;
    await db.insert('bookings', {
      'ref': b.ref,
      'user_id': userId,
      'car_id': b.carId,
      // ISO 8601 tronqué au jour : trié correctement en texte, et lisible si
      // quelqu'un ouvre la base à la main.
      'start_date': _toIso(b.startDate),
      'end_date': _toIso(b.endDate),
      'total_price': b.totalPrice,
      'status': b.status.name,
      'pick_loc': b.pickLoc,
      'ret_loc': b.retLoc,
      'pick_time': b.pickTime,
      'ret_time': b.retTime,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> setStatus(String ref, BookingStatus status) async {
    final db = await _db;
    await db.update('bookings', {'status': status.name}, where: 'ref = ?', whereArgs: [ref]);
  }

  static String _toIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Booking _fromRow(Map<String, Object?> r) => Booking(
        ref: r['ref']! as String,
        carId: r['car_id']! as String,
        startDate: DateTime.parse(r['start_date']! as String),
        endDate: DateTime.parse(r['end_date']! as String),
        totalPrice: r['total_price']! as int,
        pickLoc: r['pick_loc']! as String? ?? '',
        retLoc: r['ret_loc']! as String? ?? '',
        pickTime: r['pick_time'] as String? ?? '10:00',
        retTime: r['ret_time'] as String? ?? '10:00',
        status: BookingStatus.values.firstWhere(
          (s) => s.name == r['status'],
          orElse: () => BookingStatus.confirmed,
        ),
      );
}
