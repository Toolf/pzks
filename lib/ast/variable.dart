import 'package:pzks/ast/expression.dart';

class Variable extends Expression {
  final String identifier;

  Variable(this.identifier);

  @override
  String toString() {
    return identifier;
  }

  @override
  String toSimpleString() {
    return identifier;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Variable) return false;
    return other.toSimpleString() == toSimpleString();
  }

  @override
  int get cost => 0;
}
