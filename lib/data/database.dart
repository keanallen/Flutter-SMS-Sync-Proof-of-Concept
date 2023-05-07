import 'package:realtime_poc/data/user_model.dart';
import 'package:sqflite/sqflite.dart';

const String tableData = 'data';
const String columnId = '_id';
const String columnType = 'type';
const String columnValue = 'value';
const String columnPid = 'pid';
const String columnName = 'name';
const String columnDate = 'date';

const String tableUsers = 'users';
const String userId = 'id';
const String userMobile = 'mobile';
const String userName = 'name';
const String userOwn = 'own';

class SMSData {
  int? id;
  String? type;
  int? value;
  int? pid;
  String? name;
  String? date;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnType: type,
      columnValue: value,
      columnPid: pid,
      columnName: name,
      columnDate: date,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  SMSData();

  SMSData.fromMap(Map<String, dynamic> map) {
    type = map[columnType];
    value = map[columnValue];
    pid = map[columnPid];
    name = map[columnName];
    date = map[columnDate];
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = await getDatabasesPath();
    path = '$path/data.db';
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => _onCreate(db, version),
    );
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    print("=== DATABASE CALLED ===");

    await db.execute('''
        CREATE TABLE $tableData (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnType TEXT,
          $columnValue INTEGER,
          $columnPid INTEGER,
          $columnName TEXT,
          $columnDate TEXT
        )
      ''');

    await db.execute('''
        CREATE TABLE $tableUsers (
          $userId INTEGER PRIMARY KEY AUTOINCREMENT,
          $userMobile TEXT,
          $userName TEXT,
          $userOwn INTEGER
        )
      ''');
  }

  Future<int> insertUser(User user) async {
    final db = await this.db;
    int own = 0;

    // Check if a record with the same mobile number already exists
    final existingUsers = await db.query(
      tableUsers,
      where: '$userMobile = ?',
      whereArgs: [user.mobile],
      limit: 1,
    );

    // Delete the existing record before inserting the new record
    if (existingUsers.isNotEmpty) {
      final resultUser = User.fromMap(existingUsers.first);
      own = resultUser.own;

      user.own = own;
      await db.delete(
        tableUsers,
        where: '$userMobile = ?',
        whereArgs: [user.mobile],
      );
    }

    return await db.insert(
      tableUsers,
      user.toMap(),
    );
  }

  Future<int> insertData(SMSData data) async {
    final db = await this.db;

    final int result = await db.insert(tableData, data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<List<SMSData>> getAllData() async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(tableData);
    return List.generate(maps.length, (i) {
      return SMSData.fromMap(maps[i]);
    });
  }

  Future<List<User>> getAllUser() async {
    await Future.delayed(const Duration(seconds: 1));
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(tableUsers);
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<int> updateData(SMSData data) async {
    final db = await this.db;
    final int result = await db.update(tableData, data.toMap(),
        where: '$columnId = ?', whereArgs: [data.id]);
    return result;
  }

  Future<int> deleteData(int id) async {
    final db = await this.db;
    final int result =
        await db.delete(tableData, where: '$columnPid = ?', whereArgs: [id]);
    return result;
  }
}
