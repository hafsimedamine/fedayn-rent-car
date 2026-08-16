import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'settings_store.dart';

class SqliteSettingsStore implements SettingsStore {
  @override
  Future<Map<String, String>> readAll() async {
    try {
      final db = await AppDatabase.open();
      final rows = await db.query('settings', columns: ['key', 'value']);
      return {for (final r in rows) r['key']! as String: r['value']! as String};
    } on DatabaseException {
      // A preference read must never be able to stop the app from starting;
      // the defaults are a perfectly good answer.
      return const {};
    }
  }

  @override
  Future<void> writeAll(Map<String, String> values) async {
    try {
      final db = await AppDatabase.open();
      final batch = db.batch();
      for (final entry in values.entries) {
        batch.insert(
          'settings',
          {'key': entry.key, 'value': entry.value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } on DatabaseException {
      // Same reasoning: a failed write loses the preference, not the session.
    }
  }
}
