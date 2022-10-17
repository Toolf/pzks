import 'expression.dart';

class Numconst implements Expression {
  final double value;

  Numconst(this.value);

  @override
  String toString() {
    return "($value)";
  }
}
