import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'connect2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tag (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      );

      CREATE TABLE contact_detail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contactId TEXT
      );

      CREATE TABLE contact_detail_tag (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contactDetailId INTEGER,
        tagId INTEGER,
        FOREIGN KEY(contactDetailId) REFERENCES contact_detail(id),
        FOREIGN KEY(tagId) REFERENCES tag(id)
      );

      CREATE TABLE contact_detail_relation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        relationName TEXT,
        contactDetailId1 INTEGER,
        contactDetailId2 INTEGER,
        FOREIGN KEY(contactDetailId1) REFERENCES contact_detail(id),
        FOREIGN KEY(contactDetailId2) REFERENCES contact_detail(id)
      );
    ''');
  }

  // TODO add migration logic!
}
