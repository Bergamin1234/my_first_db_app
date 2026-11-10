# my_first_db_app — App do PG

Aplicação Flutter com persistência local em banco de dados SQLite (`sqflite`) baseada na aula **App do PG**, estendida com a função **`zerarContador()`** para zerar o contador na interface e persistir o valor `0` no banco de dados.

## Funcionalidade Implementada (`zerarContador()`)

### 1. Camada de Banco de Dados (`lib/database_helper.dart`)

Adicionado o método `zerarContador()` na classe `DatabaseHelper`, responsável por atualizar o registro `id = 1` da tabela `contador` para `valor = 0` (ou recriar o registro com `0` caso tenha sido excluído):

```dart
// zerar o contador e persistir o valor zero no banco de dados
Future<void> zerarContador() async {
  await salvarContador(0);
}
```

### 2. Camada de Interface (`lib/main.dart`)

Adicionada a função `zerarContador()` em `_MyHomePageState`, conectada tanto ao botão de reset na `AppBar` (`Icons.restart_alt`) quanto ao botão elevado **"Zerar contador"** no corpo da tela:

```dart
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
```

## Funcionalidades da Aplicação

- **Carregar contador (`carregarContador`)**: ao abrir o aplicativo (`initState`), lê o último valor persistido no SQLite.
- **Incrementar (`_incrementCounter`)**: aumenta o valor exibido na tela pelo botão flutuante (`+`).
- **Salvar (`_salvarContador`)**: persiste o valor atual do contador no banco SQLite pelo botão de salvar na `AppBar`.
- **Zerar (`zerarContador`)**: redefine o contador para `0` na tela e persiste o novo valor `0` no banco de dados SQLite, exibindo confirmação via `SnackBar`.

## Como Executar

### Dependências

```bash
flutter pub get
```

### Executar no Android / iOS / Web (Chrome)

```bash
flutter run -d chrome --web-port 8080
```

> **Suporte Web:** o projeto inclui `sqflite_common_ffi_web` (`web/sqlite3.wasm` e `web/sqflite_sw.js`) para persistência SQLite real no navegador via IndexedDB, mantendo total compatibilidade nativa com Android/iOS.

### Executar os Testes Automatizados

```bash
flutter test
```
