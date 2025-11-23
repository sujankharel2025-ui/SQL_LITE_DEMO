import 'package:hive/hive.dart';
import '../hive/hive_manager.dart';
import 'api_service.dart';

class SyncService {
  // The last sync time key in Hive
  static const String lastSyncKey = "lastSyncTime";

  // Run a full sync:
  // 1) send unsynced local messages to server
  // 2) get newer server messages and write to Hive
  static Future<void> sync() async {
    final unsynced = HiveManager.getUnsyncedMessages();
    final box = Hive.box('messagesBox');

    final lastSync = box.get(lastSyncKey, defaultValue: "1970-01-01T00:00:00.000Z") as String;

    final response = await ApiService.sync(unsynced, lastSync);
    if (response == null) {
      // failed to reach server
      return;
    }

    // 1) Mark uploaded messages as synced (we optimistically mark because server merged them)
    for (var m in unsynced) {
      final id = m['id'];
      final existing = box.get(id);
      if (existing != null) {
        final updated = Map<String, dynamic>.from(existing as Map);
        updated['isSynced'] = true;
        box.put(id, updated);
      }
    }

    // 2) Write serverMessages into Hive (serverMessages may include messages we already have)
    final serverMessages = (response['serverMessages'] as List<dynamic>?) ?? [];
    for (var m in serverMessages) {
      if (m is Map) {
        // ensure isSynced true for server-sourced items
        final item = Map<String, dynamic>.from(m as Map);
        item['isSynced'] = true;
        box.put(item['id'], item);
      }
    }

    // 3) update lastSyncTime
    final now = DateTime.now().toUtc().toIso8601String();
    box.put(lastSyncKey, now);
  }
}
