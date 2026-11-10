import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  DatabaseHelper({this.caminhoBanco});

  final String? caminhoBanco;
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
    final String caminhoCompleto;

    if (caminhoBanco != null) {
      caminhoCompleto = caminhoBanco!;
    } else if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      caminhoCompleto = 'contador.db';
    } else {
      final String pastaBanco = await getDatabasesPath();
      caminhoCompleto = join(
        pastaBanco,
        'contador.db',
      );
    }

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

  // zerar o contador e persistir o valor zero no banco de dados
  Future<void> zerarContador() async {
    await salvarContador(0);
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

  Future<void> fecharBanco() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
