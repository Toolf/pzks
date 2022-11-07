import 'dart:math';

import 'package:pzks/ast/expression.dart';

class Call extends Expression {
  final String identifier;
  final List<Expression> args;

  Call(this.identifier, this.args);

  @override
  String toString() {
    return "$identifier(${args.map((e) => args.toString()).join(',')})";
  }

  int get functionCost => 1;

  @override
  int get cost =>
      args
          .map((arg) => arg.cost)
          .reduce((cost, argCost) => max(cost, argCost)) +
      functionCost;
  @override
  String toSimpleString() {
    return "$identifier(${args.map((e) => e.toSimpleString()).join(',')})";
  }

  @override
  int get hashCode => identifier.hashCode ^ args.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Call) return false;
    return other.identifier == identifier && other.args == args;
  }
}
