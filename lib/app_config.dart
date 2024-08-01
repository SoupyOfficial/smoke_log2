import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _collectionNameKey = 'firestore_collection_name';
  static const String _jacobCollection = 'JacobLogs';
  static const String _ashleyCollection = 'AshleyLogs';

  static Future<void> setCollectionName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_collectionNameKey, name);
  }

  static Future<String> getCollectionName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_collectionNameKey) ?? _jacobCollection;
  }

  static Future<void> swapUser(Function? reload) async {
    String currentCollection = await getCollectionName();
    String newCollection = currentCollection == _jacobCollection
        ? _ashleyCollection
        : _jacobCollection;
    await setCollectionName(newCollection);
    if (reload != null) {
      reload();
    }
  }

  static Future<bool> isAshley() async {
    String collectionName = await getCollectionName();
    return collectionName.contains('Ashley');
  }
}
