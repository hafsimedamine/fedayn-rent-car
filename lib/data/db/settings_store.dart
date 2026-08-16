// Key/value storage for device preferences.

/// Small string map, deliberately separate from [AuthRepository]: preferences
/// belong to the device and outlive any one session.
abstract interface class SettingsStore {
  Future<Map<String, String>> readAll();

  /// Writes every entry in one transaction, so a half-applied change can never
  /// be observed.
  Future<void> writeAll(Map<String, String> values);
}

/// Session-scoped fallback for web, where sqflite has no implementation.
class InMemorySettingsStore implements SettingsStore {
  final Map<String, String> _values = {};

  @override
  Future<Map<String, String>> readAll() async => Map.of(_values);

  @override
  Future<void> writeAll(Map<String, String> values) async => _values.addAll(values);
}
