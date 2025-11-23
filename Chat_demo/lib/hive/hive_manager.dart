import 'package:hive/hive.dart';

class HiveManager {
  static Box get box => Hive.box('messagesBox');

  static void saveMessage(Map<String, dynamic> msg) {
    // key by id so duplicates replaced/updated easily
    box.put(msg['id'], msg);
  }

  static List<Map<String, dynamic>> getAllMessages() {
    return box.values
        .where(
          (e) => e is Map && e['id'] != null,
        ) // filter out non-message items
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList()
      ..sort(
        (a, b) =>
            (a['timestamp'] as String).compareTo(b['timestamp'] as String),
      ); // ascending
  }

  static List<Map<String, dynamic>> getUnsyncedMessages() {
    return box.values
        .where(
          (e) => e is Map && e['id'] != null,
        ) // filter out non-message items
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((m) => m['isSynced'] == false)
        .toList();
  }

  static void markAsSynced(String id) {
    final v = Map<String, dynamic>.from(box.get(id) as Map);
    v['isSynced'] = true;
    box.put(id, v);
  }

  static dynamic get(String key) => box.get(key);

  static void put(String key, dynamic value) => box.put(key, value);
}
