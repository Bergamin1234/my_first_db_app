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

  // recuperar a informação
  Future<int> buscarContador() async {
    final db = await database;

    final List<Map<String, dynamic>> resultado = await db.query(
      // SELECT * from contador WHERE id = 1
      'contador',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['valor'] as int;
    }

    return 0;
  }

  // inserir a informação atualizada
  Future<void> salvarContador(int valor) async {
    final db = await database;

    final linhasAtualizadas = await db.update(
      // UPDATE contador c SET c.valor = valor WHERE id = 1
      'contador',
      {
        'valor': valor,
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    if (linhasAtualizadas == 0) {
      await db.insert(
        'contador',
        {
          'id': 1,
          'valor': valor,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> excluirContador(int id) async {
    final db = await database;

    await db.delete(
      // DELETE from contador c where c.id = id
      'contador',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
