import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/model/parent.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteHelper {
  static final SqfliteHelper _instance = SqfliteHelper._internal();
  factory SqfliteHelper() => _instance;
  SqfliteHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'kiddo_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    //user table
    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userid TEXT,
        name TEXT,
        city TEXT,
        state TEXT,
        address TEXT,
        contact TEXT,
        email TEXT,
        mobile TEXT,
        wards INTEGER,
        status INTEGER,
        sessionid TEXT
      )
    ''');

    //child of user table
    await db.execute('''
      CREATE TABLE child(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id TEXT,
      name TEXT,
      nickname TEXT,
      school TEXT,
      class_name TEXT,
      rollno TEXT,
      age INTEGER,
      gender TEXT,
      tag_id TEXT,
      route_info TEXT,
      status INTEGER,
      onboard_status INTEGER,
      selected_plan TEXT
      )
    ''');

    //route of child table
    // await db.execute('''
    //   CREATE TABLE route(
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     route_id TEXT,
    //     route_name TEXT,
    //     oprid TEXT,
    //     vehicle_id TEXT,
    //     stop_id TEXT,
    //     stop_name TEXT,
    //     stop_arrival_time TEXT,
    //     FOREIGN KEY(child_id) REFERENCES child(id) ON DELETE CASCADE
    //   )
    // ''');
  }

  // User CRUD
  Future<int> insertUser(Parent user) async {
    final dbClient = await db;
    return await dbClient.insert('user', user.toJson());
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final dbClient = await db;
    return await dbClient.query('user');
  }

  // Child CRUD
  Future<int> insertChild(Child child) async {
    final dbClient = await db;
    return await dbClient.insert('child', child.toJson());
  }

  Future<List<Map<String, dynamic>>> getChildren(int userId) async {
    final dbClient = await db;
    return await dbClient.query('child');
  }

  //update the child
  Future<int> updateChild(Child child) async {
    final dbClient = await db;
    return await dbClient.update(
      'child',
      child.toJson(),
      where: 'student_id = ?',
      whereArgs: [child.student_id],
    );
  }

  // Route CRUD
  // Future<int> insertRoute(Map<String, dynamic> route) async {
  //   final dbClient = await db;
  //   return await dbClient.insert('route', route);
  // }

  // Future<List<Map<String, dynamic>>> getRoutes(int childId) async {
  //   final dbClient = await db;
  //   return await dbClient.query(
  //     'route',
  //     where: 'child_id = ?',
  //     whereArgs: [childId],
  //   );
  // }

  // Close the database
  Future close() async {
    final dbClient = await db;
    dbClient.close();
  }

  void clearAllData() {
    if (_db == null) return;
    try {
      _db!.delete('user');
      _db!.delete('child');
      // _db!.delete('route');
    } on Exception {
      // Do nothing
    }
  }
}
