import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:push_noti_app/car_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "cardb.db";
  static final _databaseVersion = 1;

  static final table = 'cars_table';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnMiles = 'miles';

  // make this a singleton class

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    // Laizly instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE $table ( 
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
        $columnName TEXT NOT NULL, 
        $columnMiles INTEGER NOT NULL
      )
      ''');
  }

  Future<int> insert(Car car) async {
    Database? db = await instance.database;
    return await db!.insert(table, {'name': car.name, 'miles': car.miles});
  }

  Future<List<Map<String, dynamic>>> queryAllRows(name) async {
    Database? db = await instance.database;

    return await db!.query(table, where: "$columnName LIKE '%$name%' ");
  }

  Future<int?> queryRowCount() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Car car) async {
    Database? db = await instance.database;
    int id = car.toMap()['id'];
    return await db!
        .update(table, car.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
