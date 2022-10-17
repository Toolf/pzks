import 'package:pzks/ast/expression.dart';

class Variable implements Expression {
  final String identifier;

  Variable(this.identifier);

  @override
  String toString() {
    return identifier;
  }
}
