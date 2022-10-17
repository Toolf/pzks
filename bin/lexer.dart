import 'dart:io';

import 'package:pzks/pzks.dart';

main() {
  // Зчитування виразу з стандартного входу
  final code = stdin.readLineSync();
  if (code == null) {
    stdout.write("Please write expression");
    return;
  }

  final lexer = Lexer(code);
  while (lexer.peek().tag != TokenTag.EOF) {
    final token = lexer.nextToken();
    print(token);
  }
}
