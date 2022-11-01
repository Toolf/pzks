import 'package:pzks/ast/expression.dart';

class Variable implements Expression {
  final String identifier;

  Variable(this.identifier);

  @override
  String toString() {
    return identifier;
  }

  @override
  int get hashCode => identifier.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Variable) return false;
    return other.identifier == identifier;
  }
}
