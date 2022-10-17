import 'package:pzks/ast/expression.dart';
import 'package:pzks/pzks.dart';

class UnaryOperation implements Expression {
  final String operation;
  final Expression expression;

  UnaryOperation(this.operation, this.expression);

  @override
  String toString() {
    final s = this.expression.toString();
    final l = s.length;
    return "${centrize("($operation)", l)}\n${centrize("|", l)}\n$s";
  }
}
