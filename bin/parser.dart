import 'dart:io';

import 'package:pzks/pzks.dart';

main() {
  // Зчитування виразу з стандартного входу
  final code = stdin.readLineSync();
  if (code == null) {
    stdout.write("Please write expression");
    return;
  }

  try {
    // Парсинг визару
    final parser = Parser(code);
    parser.parse();

    // Вивід помилок
    for (var e in parser.errors) {
      print("-" * 50);
      print(highlight(code.split("\n")[e.fromRow], e));
    }
    if (parser.errors.isEmpty) {
      print("Errors not found");
    }
  } on LexerException catch (e) {
    // only for development needs
    print("Lexer Exception: ${e.message}");
  }
}
