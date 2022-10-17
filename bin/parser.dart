import 'dart:io';

import 'package:pzks/ast/binary_operation.dart';
import 'package:pzks/ast/numconst.dart';
import 'package:pzks/ast/unary_operation.dart';
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
    parser.validate();

    // Вивід помилок
    for (var e in parser.errors) {
      print("-" * 50);
      print(highlight(code.split("\n")[e.fromRow], e));
    }
    if (parser.errors.isEmpty) {
      print("Errors not found");
      print(parser.parse());
    }
  } on LexerException catch (e) {
    // only for development needs
    print("Lexer Exception: ${e.message}");
  }
}
