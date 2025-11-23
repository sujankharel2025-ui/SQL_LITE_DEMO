import '../database/database_helper.dart';
import 'api_service.dart';

class SyncService {
  // The last sync time key in database
  static const String lastSyncKey = "lastSyncTime";

  // Run a full sync:
  // 1) send unsynced local messages to server
  // 2) get newer server messages and write to database
  static Future<void> sync() async {
    // Get unsynced messages from database (ASYNC now!)
    final unsynced = await DatabaseHelper.getUnsyncedMessages();

    // Get last sync time from database
    final lastSync =
        await DatabaseHelper.getSetting(
          lastSyncKey,
          defaultValue: "1970-01-01T00:00:00.000Z",
        ) ??
        "1970-01-01T00:00:00.000Z";

    final response = await ApiService.sync(unsynced, lastSync);
    if (response == null) {
      // failed to reach server
      return;
    }

    // 1) Mark uploaded messages as synced (we optimistically mark because server merged them)
    for (var m in unsynced) {
      final id = m['id'];
      await DatabaseHelper.markAsSynced(id);
    }

    // 2) Write serverMessages into database (serverMessages may include messages we already have)
    final serverMessages = (response['serverMessages'] as List<dynamic>?) ?? [];
    for (var m in serverMessages) {
      if (m is Map) {
        // ensure isSynced true for server-sourced items
        final item = Map<String, dynamic>.from(m as Map);
        item['isSynced'] = true;
        await DatabaseHelper.saveMessage(item);
      }
    }

    // 3) update lastSyncTime
    final now = DateTime.now().toUtc().toIso8601String();
    await DatabaseHelper.saveSetting(lastSyncKey, now);
  }
}
