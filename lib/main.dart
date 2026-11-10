import 'package:flutter/material.dart';
import 'package:my_first_db_app/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
        ),
      ),
      home: const MyHomePage(
        title: 'App do PG',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    // Ao abrir o aplicativo,
    // carrega o valor salvo no banco
    carregarContador();
  }

  // Método responsável por buscar
  // o valor salvo no SQLite
  Future<void> carregarContador() async {
    final valorSalvo = await databaseHelper.buscarContador();

    if (!mounted) return;

    setState(() {
      _counter = valorSalvo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
