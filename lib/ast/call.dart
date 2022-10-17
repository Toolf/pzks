import 'package:pzks/ast/expression.dart';

class Call implements Expression {
  final String identifier;
  final List<Expression> args;

  Call(this.identifier, this.args);

  @override
  String toString() {
    return "$identifier(${args.map((e) => args.toString()).join(',')})";
  }
}
