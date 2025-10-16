import 'package:sqflite/sqflite.dart';
import '../../core/models/user.dart'; // RUTA CORREGIDA
import '../local/db_helper.dart';

class UserRepository {
  Future<AppUser?> getByEmail(String email) async {
    final db = await DBHelper.instance.database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (res.isEmpty) return null;
    return AppUser.fromMap(res.first);
  }

  Future<int> create(AppUser user) async {
    final db = await DBHelper.instance.database;
    return db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }
}