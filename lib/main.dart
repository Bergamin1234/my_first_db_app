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

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
  }

  Future<void> _salvarContador() async {
    await databaseHelper.salvarContador(_counter);
    _mostrarMensagem('Valor salvo com sucesso!');
  }

  // Método responsável por zerar o contador
  // e persistir o valor zero no SQLite
  Future<void> zerarContador() async {
    await databaseHelper.zerarContador();

    if (!mounted) return;

    setState(() {
      _counter = 0;
    });

    _mostrarMensagem('Contador zerado e salvo com sucesso!');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _salvarContador,
            tooltip: 'Salvar contador',
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: zerarContador,
            tooltip: 'Zerar contador',
            icon: const Icon(Icons.restart_alt),
          ),
        ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
