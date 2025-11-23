import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'chat_database.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _messagesTable = 'messages';
  static const String _settingsTable = 'settings';

  // Message columns
  static const String colId = 'id';
  static const String colText = 'text';
  static const String colSender = 'sender';
  static const String colTimestamp = 'timestamp';
  static const String colIsSynced = 'isSynced';

  // Settings columns
  static const String colKey = 'key';
  static const String colValue = 'value';

  // Singleton pattern - only one database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create tables
  static Future<void> _onCreate(Database db, int version) async {
    // Messages table
    await db.execute('''
      CREATE TABLE $_messagesTable (
        $colId TEXT PRIMARY KEY,
        $colText TEXT NOT NULL,
        $colSender TEXT NOT NULL,
        $colTimestamp TEXT NOT NULL,
        $colIsSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Settings table (for storing lastSyncTime and other settings)
    await db.execute('''
      CREATE TABLE $_settingsTable (
        $colKey TEXT PRIMARY KEY,
        $colValue TEXT NOT NULL
      )
    ''');
  }

  // Save a message (replaces Hive's saveMessage)
  static Future<void> saveMessage(Map<String, dynamic> msg) async {
    final db = await database;
    await db.insert(
      _messagesTable,
      {
        colId: msg['id'],
        colText: msg['text'],
        colSender: msg['sender'],
        colTimestamp: msg['timestamp'],
        colIsSynced: msg['isSynced'] == true ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if exists
    );
  }

  // Get all messages (replaces Hive's getAllMessages)
  static Future<List<Map<String, dynamic>>> getAllMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _messagesTable,
      orderBy: '$colTimestamp ASC', // Sort by timestamp
    );

    // Convert isSynced from int to bool
    return maps.map((map) {
      return {
        'id': map[colId],
        'text': map[colText],
        'sender': map[colSender],
        'timestamp': map[colTimestamp],
        'isSynced': map[colIsSynced] == 1,
      };
    }).toList();
  }

  // Get unsynced messages (replaces Hive's getUnsyncedMessages)
  static Future<List<Map<String, dynamic>>> getUnsyncedMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _messagesTable,
      where: '$colIsSynced = ?',
      whereArgs: [0], // 0 = false (not synced)
    );

    return maps.map((map) {
      return {
        'id': map[colId],
        'text': map[colText],
        'sender': map[colSender],
        'timestamp': map[colTimestamp],
        'isSynced': map[colIsSynced] == 1,
      };
    }).toList();
  }

  // Mark message as synced (replaces Hive's markAsSynced)
  static Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      _messagesTable,
      {colIsSynced: 1}, // 1 = true (synced)
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // Get a setting value (replaces Hive's get for settings)
  static Future<String?> getSetting(String key, {String? defaultValue}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _settingsTable,
      where: '$colKey = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return defaultValue;
    return maps.first[colValue] as String?;
  }

  // Save a setting value (replaces Hive's put for settings)
  static Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(_settingsTable, {
      colKey: key,
      colValue: value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Delete a message (optional - for cleanup)
  static Future<void> deleteMessage(String id) async {
    final db = await database;
    await db.delete(_messagesTable, where: '$colId = ?', whereArgs: [id]);
  }

  // Clear all messages (optional - for testing)
  static Future<void> clearAllMessages() async {
    final db = await database;
    await db.delete(_messagesTable);
  }

  // Close database (optional - usually handled automatically)
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
