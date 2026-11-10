import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_db_app/database_helper.dart';
import 'package:my_first_db_app/main.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('MyApp', () {
    late Directory tempDir;
    late String dbPath;
    late DatabaseHelper dbHelper;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('my_first_db_app_widget_');
      dbPath = p.join(tempDir.path, 'contador.db');
      dbHelper = DatabaseHelper(caminhoBanco: dbPath);
    });

    tearDown(() async {
      await dbHelper.fecharBanco();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets('incrementa, salva e zera o contador persistindo no banco', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MyApp(databaseHelper: dbHelper));
      await tester.runAsync(() async {
        await dbHelper.buscarContador();
      });
      await tester.pumpAndSettle();

      expect(find.text('App do PG'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('3'), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.byIcon(Icons.save));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(find.text('Valor salvo com sucesso!'), findsOneWidget);

      final valorPersistido = await tester.runAsync(
        () => dbHelper.buscarContador(),
      );
      expect(valorPersistido, equals(3));

      await tester.runAsync(() async {
        await tester.tap(find.text('Zerar contador'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('3'), findsNothing);
      expect(find.text('Contador zerado e salvo com sucesso!'), findsOneWidget);

      final valorAposZerar = await tester.runAsync(
        () => dbHelper.buscarContador(),
      );
      expect(valorAposZerar, equals(0));
    });

    testWidgets(
      'botão da AppBar também executa zerarContador e persiste zero',
      (WidgetTester tester) async {
        await tester.runAsync(() => dbHelper.salvarContador(9));

        await tester.pumpWidget(MyApp(databaseHelper: dbHelper));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pumpAndSettle();

        expect(find.text('9'), findsOneWidget);

        await tester.runAsync(() async {
          await tester.tap(find.byIcon(Icons.restart_alt));
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pumpAndSettle();

        expect(find.text('0'), findsOneWidget);
        expect(
          find.text('Contador zerado e salvo com sucesso!'),
          findsOneWidget,
        );

        final valorAposZerar = await tester.runAsync(
          () => dbHelper.buscarContador(),
        );
        expect(valorAposZerar, equals(0));
      },
    );
  });
}
