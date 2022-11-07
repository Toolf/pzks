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
  int get hashCode => identifier.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Variable) return false;
    return other.identifier == identifier;
  }

  @override
  int get cost => 0;
}
