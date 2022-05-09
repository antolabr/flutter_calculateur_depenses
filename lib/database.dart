import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'depenses.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();
  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static late Database _database;
  Future<Database> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "depenses.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE depenses (id INTEGER PRIMARY KEY, montant REAL, date TEXT, categorie TEXT)",
        );
        await db.execute(
          "INSERT INTO depenses (id, montant, date, categorie) VALUES (?, ?, ?, ?)",
          [1, 100, '2020-01-01', 'food'],
        );
      },
    );
  }

  Future<List<Depenses>> getAllDepenses() async {
    final db = await database;
    List<Map> result = await db.query("depenses", columns: Depenses.columns, orderBy: 'date DESC');
    List<Depenses> depenses = [];
    for (var element in result) {
      depenses.add(
        Depenses.fromMap(element),
      );
    }
    return depenses;
  }

  Future<Depenses?> getDepensesById(int id) async {
    final db = await database;
    var result = await db.query(
      "depenses",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? Depenses.fromMap(result.first) : null;
  }

  Future<double> getTotalDepenses() async {
    final db = await database;
    List<Map> list = await db.rawQuery(
      "SELECT SUM(montant) FROM depenses",
    );
    return list.isNotEmpty ? list.first['SUM(montant)'] : null;
  }

  Future<Depenses> insertDepenses(Depenses depenses) async {
    final db = await database;
    var maxIdResult = await db.rawQuery(
      "SELECT Max(id)+1 AS last_id FROM depenses",
    );
    var id = int.parse(maxIdResult.first['last_id'].toString()); //renvoie un objet => à caster
    await db.rawQuery(
      'INSERT INTO depenses (id,montant,date,categorie) VALUES (?,?,?,?)',
      [id, depenses.montant, depenses.date.toString(), depenses.categorie],
    );
    return Depenses(id, depenses.montant, depenses.date, depenses.categorie);
  }

  Future<int> updateDepenses(Depenses depenses) async {
    final db = await database;
    var result = await db.update(
      'depenses',
      depenses.toMap(),
      where: 'id = ?',
      whereArgs: [depenses.id],
    );
    return result;
  }

  Future<int> deleteDepenses(int id) async {
    final db = await database;
    return await db.delete(
      'depenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
