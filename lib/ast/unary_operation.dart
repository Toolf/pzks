import 'package:pzks/ast/expression.dart';
import 'package:pzks/pzks.dart';

class UnaryOperation extends Expression {
  final String operation;
  final Expression expression;

  UnaryOperation(this.operation, this.expression);

  @override
  String toString() {
    final s = expression.toString();
    final l = s.length;
    return "${centrize("($operation)", l)}\n${centrize("|", l)}\n$s";
  }

  @override
  String toSimpleString() {
    return "$operation${expression.toSimpleString()}";
  }

  @override
  bool operator ==(Object other) {
    if (other is! UnaryOperation) return false;
    return other.toSimpleString() == toSimpleString();
  }

  int operationCost(String operation) {
    return 1;
  }

  @override
  int get cost => expression.cost + operationCost(operation);
}
