import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_db_app/database_helper.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper', () {
    late Directory tempDir;
    late String dbPath;
    late DatabaseHelper dbHelper;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('my_first_db_app_test_');
      dbPath = p.join(tempDir.path, 'contador.db');
      dbHelper = DatabaseHelper(caminhoBanco: dbPath);
    });

    tearDown(() async {
      await dbHelper.fecharBanco();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('inicia tabela contador com valor zero', () async {
      final valorInicial = await dbHelper.buscarContador();
      expect(valorInicial, equals(0));
    });

    test('salvarContador persiste novo valor entre sessões', () async {
      await dbHelper.salvarContador(7);
      expect(await dbHelper.buscarContador(), equals(7));

      await dbHelper.fecharBanco();

      final novaInstancia = DatabaseHelper(caminhoBanco: dbPath);
      expect(await novaInstancia.buscarContador(), equals(7));
      await novaInstancia.fecharBanco();
    });

    test('zerarContador persiste zero no banco de dados', () async {
      await dbHelper.salvarContador(15);
      expect(await dbHelper.buscarContador(), equals(15));

      await dbHelper.zerarContador();
      expect(await dbHelper.buscarContador(), equals(0));

      await dbHelper.fecharBanco();

      final novaInstancia = DatabaseHelper(caminhoBanco: dbPath);
      expect(await novaInstancia.buscarContador(), equals(0));
      await novaInstancia.fecharBanco();
    });

    test(
      'zerarContador restaura registro com zero mesmo após exclusão',
      () async {
        await dbHelper.salvarContador(10);
        await dbHelper.excluirContador(1);
        expect(await dbHelper.buscarContador(), equals(0));

        await dbHelper.zerarContador();
        expect(await dbHelper.buscarContador(), equals(0));
      },
    );
  });
}
