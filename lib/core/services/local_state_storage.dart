import 'package:shared_preferences/shared_preferences.dart';

/// Fronteira pequena para testar falhas sem acessar preferências pessoais.
abstract interface class LocalStateStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> remove();
}

class PreferencesStateStorage implements LocalStateStorage {
  PreferencesStateStorage({SharedPreferencesAsync? preferences})
    : _providedPreferences = preferences;

  static const key = 'soundwave.state.v1';
  final SharedPreferencesAsync? _providedPreferences;

  // Inicialização tardia permite ao repositório tratar falha do plugin na carga.
  SharedPreferencesAsync get _preferences =>
      _providedPreferences ?? SharedPreferencesAsync();

  @override
  Future<String?> read() async => _preferences.getString(key);

  @override
  Future<void> write(String value) async => _preferences.setString(key, value);

  @override
  Future<void> remove() async => _preferences.remove(key);
}
