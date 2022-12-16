import 'dart:collection';
import 'dart:core';

class Command {
  final List<String> operands;
  final String result;
  final String operation;
  final int executionTime;

  Command(this.operands, this.result, this.operation, this.executionTime);

  @override
  String toString() {
    return "Command(operands: $operands, res: $result, operations: $operation, execTime: $executionTime)";
  }
}

class Processor {
  int executionTime = 0;
  Command? command;

  Processor(this.command);
}

class Dataflow {
  final List<Command> code;
  final Set<String> inputValues;
  final int time = 0;
  final _calculatedValues = <String>{};
  final _queue = Queue<Command>();

  final processors = <Processor>[];

  Dataflow(this.code, this.inputValues, processorCount) {
    // Визначення команд які можуть виконуватись
    _calculatedValues.addAll(inputValues);
    for (var command in code) {
      if (_calculatedValues.containsAll(command.operands)) {
        _queue.add(command);
      }
    }
    // Ініціалізація процесорів
    for (var i = 0; i < processorCount; i++) {
      processors.add(Processor(null));
    }
    // Завантаження команд на процесори
    for (var i = 0; i < processorCount; i++) {
      if (_queue.isEmpty) break;

      final command = _queue.removeFirst();
      processors[i].command = command;
      processors[i].executionTime = 0;
    }
  }

  tact() {
    // Виконання такту
    for (var processor in processors) {
      if (processor.command != null) {
        processor.executionTime++;
      }
    }
    // Визначення команд які виконались та вигрузка результатів
    for (var processor in processors) {
      if (processor.command != null &&
          processor.executionTime == processor.command!.executionTime) {
        _calculatedValues.add(processor.command!.result);
        processor.command = null;
      }
    }
    // Визначення команд які можуть виконуватись
    for (var command in code) {
      if (!_calculatedValues.contains(command.result) &&
          !_queue.contains(command) &&
          _calculatedValues.containsAll(command.operands) &&
          !processors.any((p) => p.command == command)) {
        _queue.add(command);
      }
    }
    // Завантаженя команд в вільні процесори
    for (var processor in processors) {
      if (_queue.isEmpty) break;
      if (processor.command != null) continue;
      final command = _queue.removeFirst();
      processor.command = command;
      processor.executionTime = 0;
    }
  }

  canExecute() {
    return _queue.isNotEmpty || processors.any((p) => p.command != null);
  }
}
