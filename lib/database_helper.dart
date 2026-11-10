import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Database? _database;

  // criar o db
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _iniciarBanco();
    return _database!;
  }

  Future<Database> _iniciarBanco() async {
    final String caminhoBanco = await getDatabasesPath();

    final String caminhoCompleto = join(
      caminhoBanco,
      'contador.db',
    );

    // criar a tabela
    return await openDatabase(
      caminhoCompleto,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contador (
            id INTEGER PRIMARY KEY,
            valor INTEGER NOT NULL
          )
        ''');

        await db.insert(
          // INSERT INTO contador values(1,0)
          'contador',
          {
            'id': 1,
            'valor': 0,
          },
        );
      },
    );
  }
}
