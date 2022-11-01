// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:math';

import 'package:pzks/ast/expression.dart';

import '../helper.dart';

class BinaryOperation implements Expression {
  final Expression left;
  final Expression right;
  final String operation;

  BinaryOperation(this.operation, this.left, this.right);

  @override
  String toString() {
    final lstring = left.toString();
    final rstring = right.toString();
    var lwidth = lstring.indexOf("\n");
    lwidth = lwidth == -1 ? lstring.length : lwidth;
    var rwidth = rstring.indexOf("\n");
    rwidth = rwidth == -1 ? rstring.length : rwidth;
    final width = max(rwidth, lwidth);
    final content = [];
    final llines = lstring.split("\n");
    final rlines = rstring.split("\n");
    for (int i = 0; i < max(llines.length, rlines.length); i++) {
      var line = "";
      line += centrize(
        llines.length <= i ? " " * llines[0].length : llines[i],
        width,
      );
      line += " " * "($operation)".length;
      line += centrize(
        rlines.length <= i ? " " * rlines[0].length : rlines[i],
        width,
      );
      content.add(line);
    }
    return " " * (width ~/ 2) +
        "|" +
        "-" * (width - width ~/ 2 - 1) +
        "($operation)" +
        "-" * (width - width ~/ 2 - 1) +
        "|" +
        " " * (width ~/ 2) +
        "\n" +
        " " * (width ~/ 2) +
        "|" +
        " " * ((width - width ~/ 2 - 1) * 2 + "($operation)".length) +
        "|" +
        " " * (width ~/ 2) +
        "\n" +
        content.join("\n");
  }

  @override
  int get hashCode => left.hashCode ^ right.hashCode ^ operation.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! BinaryOperation) return false;
    return other.operation == operation &&
        other.left == left &&
        other.right == right;
  }
}
