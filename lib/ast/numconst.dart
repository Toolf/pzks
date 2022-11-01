import 'expression.dart';

class Numconst implements Expression {
  final double value;

  Numconst(this.value);

  @override
  String toString() {
    return "($value)";
  }

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Numconst) return false;
    return other.value == value;
  }
}
