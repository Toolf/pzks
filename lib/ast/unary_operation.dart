import 'package:pzks/ast/expression.dart';
import 'package:pzks/pzks.dart';

class UnaryOperation implements Expression {
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
  int get hashCode => expression.hashCode ^ operation.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! UnaryOperation) return false;
    return other.expression == expression && other.operation == operation;
  }
}
