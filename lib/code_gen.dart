import 'package:pzks/ast/binary_operation.dart';
import 'package:pzks/ast/expression.dart';
import 'package:pzks/ast/numconst.dart';
import 'package:pzks/ast/unary_operation.dart';
import 'package:pzks/ast/variable.dart';

import 'dataflow.dart';

class CodeGenResult {
  final List<Command> code;
  final Map<String, String> inputValues;

  CodeGenResult(this.code, this.inputValues);
}

class DataflowCodeGen {
  int id = 0;
  final Map<String, int> executionTimes;
  DataflowCodeGen(this.executionTimes);

  genId() {
    return "id-${(++id)}";
  }

  CodeGenResult generate(Expression expression, [String? id]) {
    if (expression is BinaryOperation) return _generateBinOp(expression, id);
    if (expression is UnaryOperation) return _generateUnaryOp(expression, id);
    if (expression is Variable) return _generateVariable(expression, id);
    if (expression is Numconst) return _generateNumconst(expression, id);
    throw Exception("Invalid expression type");
  }

  CodeGenResult _generateBinOp(BinaryOperation binOp, String? id) {
    id ??= genId();
    final leftId = genId();
    final rightId = genId();
    final left = generate(binOp.left, leftId);
    final right = generate(binOp.right, rightId);

    return CodeGenResult(
      [
        ...left.code,
        ...right.code,
        Command(
          [leftId, rightId],
          id!,
          binOp.operation,
          executionTimes[binOp.operation]!,
        ),
      ],
      {...left.inputValues, ...right.inputValues},
    );
  }

  CodeGenResult _generateUnaryOp(UnaryOperation unaryOp, String? id) {
    id ??= genId();
    final exprId = genId();
    final expr = generate(unaryOp.expression, exprId);
    return CodeGenResult(
      [
        ...expr.code,
        Command(
          [exprId],
          id!,
          unaryOp.operation,
          executionTimes[unaryOp.operation]!,
        ),
      ],
      {...expr.inputValues},
    );
  }

  CodeGenResult _generateNumconst(Numconst numconst, String? id) {
    id ??= genId();
    return CodeGenResult([], {id!: numconst.value.toString()});
  }

  CodeGenResult _generateVariable(Variable variable, String? id) {
    id ??= genId();
    return CodeGenResult([], {id!: variable.identifier});
  }
}
