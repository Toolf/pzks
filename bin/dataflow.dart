import 'dart:io';

import 'package:pzks/code_gen.dart';
import 'package:pzks/dataflow.dart';
import 'package:pzks/pzks.dart';

main() {
  // Вхідна дані
  final executionTimes = {
    "*": 5,
    "/": 3,
    "-": 2,
    "+": 1,
  };
  final processorCount = 4;
  // Зчитування виразу з стандартного входу
  final code = /*"1+2+3+4+5+6+7+8+9+10";*/ stdin.readLineSync();

  if (code == null) {
    stdout.write("Please write expression");
    return;
  }

  try {
    // Парсинг визару
    final parser = Parser(code, executionTimes);
    parser.validate();

    // Вивід помилок
    for (var e in parser.errors) {
      print("-" * 50);
      print(highlight(code.split("\n")[e.fromRow], e));
    }
    if (parser.errors.isEmpty) {
      print("Errors not found");
      final expr = parser.parse();
      // Вивід синтаксичного дерева
      print(expr);

      // Генерація Dataflow коду
      final codeGen = DataflowCodeGen(executionTimes);
      final genRes = codeGen.generate(expr);

      // Симуляція роботи системи
      final dataflow = Dataflow(
        genRes.code,
        genRes.inputValues.keys.toSet(),
        processorCount,
      );

      // Вивід коду
      print(genRes.code.map((c) => c.toString()).join('\n'));
      // Вивід вхідних значень
      print(genRes.inputValues);
      int step = 0;
      do {
        // Вивід стану системи
        print(
          "$step)\t${dataflow.processors.map((p) => '|\t${p.command?.result ?? ''}\t|').join('')}",
        );
        // Виконання такту
        dataflow.tact();
        step++;
      } while (dataflow.canExecute());
    }
  } on LexerException catch (e) {
    // only for development needs
    print("Lexer Exception: ${e.message}");
  }
}
