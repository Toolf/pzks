import 'expression.dart';

class Numconst extends Expression {
  final double value;

  Numconst(this.value);

  @override
  String toString() {
    return "($value)";
  }

  @override
  String toSimpleString() {
    return "$value";
  }

  @override
  bool operator ==(Object other) {
    if (other is! Numconst) return false;
    return other.toSimpleString() == toSimpleString();
  }

  @override
  int get cost => 0;
}
