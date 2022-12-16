import 'package:pzks/ast/binary_operation.dart';
import 'package:pzks/ast/numconst.dart';
import 'package:pzks/ast/unary_operation.dart';

import 'package:collection/collection.dart';

import 'ast/call.dart';
import 'ast/expression.dart';
import 'ast/variable.dart';
import 'lexer.dart';

class SyntaxError {
  final String message;
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;

  SyntaxError(
    this.message,
    this.fromRow,
    this.fromCol,
    this.toRow,
    this.toCol,
  );

  @override
  String toString() {
    return "$message, from ($fromRow, $fromCol) to ($toRow, $toCol)";
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SyntaxError &&
        other.message == other.message &&
        other.fromRow == fromRow &&
        other.toRow == toRow &&
        other.toCol == toCol;
  }

  @override
  int get hashCode => message.hashCode ^ fromRow ^ fromCol ^ toRow ^ toCol;
}

class ArgDeclaration {
  ArgDeclaration();
}

class FunctionDeclaration {
  final String name;
  final List<ArgDeclaration> args;

  FunctionDeclaration(
    this.name,
    this.args,
  );
}

class Parser {
  final String code;
  final Lexer _lexer;

  static const sumOp = [TokenTag.PLUS, TokenTag.MINUS];
  static const mulOp = [TokenTag.STAR, TokenTag.SLASH];
  static const unaryOp = [TokenTag.PLUS, TokenTag.MINUS];
  final errors = [];

  final List<FunctionDeclaration> functions;
  final Map<String, int> executionTimes;
  Parser(this.code, this.executionTimes, [this.functions = const []])
      : _lexer = Lexer(code);

  validate() {
    _lexer.reset();
    var peekBefore = _lexer.peek();
    final expr = _validateExpression();
    var peekAfter = _lexer.peek();
    while (peekAfter.tag != TokenTag.EOF) {
      if (peekBefore == peekAfter) {
        skipToken();
      } else {
        errors.add(
          SyntaxError(
            "Expect operation",
            peekAfter.row,
            peekAfter.col,
            peekAfter.row,
            peekAfter.col + 1,
          ),
        );
      }
      peekBefore = _lexer.peek();
      _validateExpression();
      peekAfter = _lexer.peek();
    }
    return expr;
  }

  Expression parse() {
    _lexer.reset();
    final expr = _parseExpression();
    return expr;
  }

  skipToken() {
    _lexer.nextToken();
  }

  _expected(List<TokenTag> tags) {
    bool found = false;
    final peek = _lexer.peek();
    bool errorFound = !tags.contains(peek.tag);
    final startRow = peek.row;
    final startCol = peek.col;
    int endRow = startRow;
    int endCol = startCol;
    while (_lexer.peek().tag != TokenTag.EOF) {
      final peek = _lexer.peek();
      if (tags.contains(peek.tag)) {
        found = true;
        break;
      }

      _lexer.nextToken();
      endRow = peek.row;
      endCol = peek.col + peek.value.length;
    }
    if (errorFound) {
      errors.add(
        SyntaxError(
          "Expected ${tags.map((t) => t.value).join(' or ')}",
          startRow,
          startCol,
          endRow,
          endCol,
        ),
      );
    } else if (!found) {
      final peek = _lexer.peek();
      errors.add(
        SyntaxError(
          "Expected ${tags.map((t) => t.value).join(' or ')}",
          peek.row,
          peek.col,
          peek.row,
          peek.col + peek.value.length,
        ),
      );
    }
  }

  bool _isFunctionName(name) {
    return functions.map((f) => f.name).toList().contains(name);
  }

  _validateExpression() {
    final l = _validateMulExpression();
    while (sumOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken();
      final r = _validateMulExpression();
    }
  }

  _validateMulExpression() {
    final l = _validateUnaryExpression();
    while (mulOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken();
      final r = _validateUnaryExpression();
    }
  }

  _validateUnaryExpression() {
    if (unaryOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken();
      final unaryExpr = _validateUnaryExpression();
    } else {
      _expected([TokenTag.LPAR, TokenTag.ID, TokenTag.NUMCONST]);
      final factor = _validateFactor();
    }
  }

  _validateFactor() {
    var peek = _lexer.peek();
    if (peek.tag == TokenTag.LPAR) {
      _lexer.nextToken();
      final expr = _validateExpression();
      _expected([TokenTag.RPAR]);
      _lexer.nextToken();
      return expr;
    }
    if (peek.tag == TokenTag.ID) {
      final callOrId = _validateCallOrId();
      return callOrId;
    }
    if (peek.tag == TokenTag.NUMCONST) {
      final numconst = _lexer.nextToken();
      return numconst;
    }

    // bad factor
  }

  _validateCallOrId() {
    final id = _lexer.nextToken();
    final peek = _lexer.peek();
    if (peek.tag == TokenTag.LPAR && !_isFunctionName(id.value)) {
      errors.add(
        SyntaxError(
          "The expression doesn't evaluate to a function, so it can't be invoked",
          peek.row,
          peek.col,
          peek.row,
          peek.col + peek.value.length,
        ),
      );
    }
    if (_isFunctionName(id.value)) {
      // check start with '('
      _expected([TokenTag.LPAR]);
      _lexer.nextToken();
      final peek = _lexer.peek();
      if (peek.tag != TokenTag.RPAR) {
        final argsCount = _validateArgs();
        final endPeek = _lexer.peek();
        if (argsCount !=
            functions.firstWhere((f) => id.value == f.name).args.length) {
          errors.add(
            SyntaxError(
              "Invalid arguments count",
              peek.row,
              peek.col,
              endPeek.row,
              endPeek.col + endPeek.value.length,
            ),
          );
        }
      }

      _expected([TokenTag.RPAR]);
      _lexer.nextToken();
    }
  }

  int _validateArgs() {
    int count = 1;
    final expr = _validateExpression();
    while (_lexer.peek().tag == TokenTag.COMMA) {
      _lexer.nextToken();
      final args = _validateExpression();
      count++;
    }
    return count;
  }

  Expression _parseExpression() {
    final binOps = [_parseMulExpression()];
    final operations = <String>[];
    while (sumOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken().value;
      final r = _parseMulExpression();
      operations.add(op);
      binOps.add(r);
    }
    return _minimizeBinOp(binOps, operations);
  }

  Expression _parseMulExpression() {
    final binOps = [_parseUnaryExpression()];
    final operations = <String>[];
    while (mulOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken().value;
      final r = _parseUnaryExpression();
      operations.add(op);
      binOps.add(r);
    }
    return _minimizeBinOp(binOps, operations);
  }

  Expression _minimizeBinOp(
    List<Expression> binaryOperations,
    List<String> operations,
  ) {
    if (binaryOperations.length == 1) return binaryOperations[0];
    final binOp = _buildBinaryTree(binaryOperations, operations);
    return binOp;
  }

  Expression _buildBinaryTree(
    List<Expression> binaryOperations,
    List<String> operations, [
    bool invert = false,
  ]) {
    final invertOperations = {
      "*": "/",
      "/": "*",
      "+": "-",
      "-": "+",
    };
    if (binaryOperations.length == 1) return binaryOperations[0];
    if (binaryOperations.length == 2) {
      return BinaryOperation(
        invert ? invertOperations[operations[0]]! : operations[0],
        binaryOperations[0],
        binaryOperations[1],
        executionTimes,
      );
    }
    var lSize = 1;
    var lCost = binaryOperations[0].cost;
    var rCost = binaryOperations.skip(1).map((b) => b.cost).sum +
        operations.map((o) => executionTimes[o]!).sum;
    for (int i = 1; i < binaryOperations.length; i++) {
      final bCost =
          binaryOperations[i].cost + executionTimes[operations[i - 1]]!;
      if (lCost + bCost >= rCost) {
        break;
      }
      lSize++;
      lCost += bCost;
      rCost -= bCost;
    }

    final op = invert
        ? invertOperations[operations[lSize - 1]]!
        : operations[lSize - 1];
    bool childInvert = invert ^ (op == "-" || op == '/');
    return BinaryOperation(
      op,
      _buildBinaryTree(
        binaryOperations.sublist(0, lSize),
        operations.sublist(0, lSize - 1),
        invert,
      ),
      _buildBinaryTree(
        binaryOperations.sublist(lSize),
        operations.sublist(lSize),
        childInvert,
      ),
      executionTimes,
    );
  }

  Expression _parseUnaryExpression() {
    if (unaryOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken().value;
      final unaryExpr = _parseUnaryExpression();
      return UnaryOperation(op, unaryExpr);
    } else {
      final factor = _parseFactor();
      return factor;
    }
  }

  Expression _parseFactor() {
    var peek = _lexer.peek();
    if (peek.tag == TokenTag.LPAR) {
      _lexer.nextToken();
      final expr = _parseExpression();
      _lexer.nextToken();
      return expr;
    }
    if (peek.tag == TokenTag.ID) {
      final callOrId = _parseCallOrId();
      return callOrId;
    }
    if (peek.tag == TokenTag.NUMCONST) {
      final numconst = _lexer.nextToken().value;
      return Numconst(double.parse(numconst));
    }
    throw Exception("Expected invalid validation");
  }

  Expression _parseCallOrId() {
    final identifier = _lexer.nextToken().value;
    if (_isFunctionName(identifier)) {
      _lexer.nextToken();
      var args = <Expression>[];
      if (_lexer.peek().tag != TokenTag.RPAR) {
        args = _parseArgs();
      }

      _lexer.nextToken();
      return Call(identifier, args);
    }
    return Variable(identifier);
  }

  List<Expression> _parseArgs() {
    final args = [_parseExpression()];
    while (_lexer.peek().tag == TokenTag.COMMA) {
      _lexer.nextToken();
      args.add(_parseExpression());
    }
    return args;
  }

  Set<String> genSimilar() {
    _lexer.reset();
    return _genSimilar();
  }

  Set<String> _genSimilar() {
    final binOps = [_genSimilarMulExpression()];
    final operations = <String>[];
    while (sumOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken().value;
      final r = _genSimilarMulExpression();
      operations.add(op);
      binOps.add(r);
    }
    return _genSimilarBinOp(binOps, operations);
  }

  Set<String> _genSimilarMulExpression() {
    final binOps = [_genSimilarUnaryOp()];
    final operations = <String>[];
    while (mulOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken().value;
      final r = _genSimilarUnaryOp();
      operations.add(op);
      binOps.add(r);
    }
    return _genSimilarBinOp(binOps, operations);
  }

  Set<String> _genSimilarBinOp(
      List<Set<String>> binOp, List<String> operations) {
    if (binOp.length == 1) return binOp[0];
    final invertOperations = {
      "*": "/",
      "/": "*",
      "+": "-",
      "-": "+",
    };
    final res = <String>{};

    final baseOperation = operations.first == "+" || operations.first == "*"
        ? operations.first
        : invertOperations[operations.first]!;
    operations = [baseOperation, ...operations];

    // Асоціативність
    res.addAll(_flatten(binOp, operations));

    // Комутативність
    // final pairs = [
    //   ...IterableZip([operations, binOp])
    // ];

    // final combinations = _combinations(pairs);

    // for (final combo in combinations) {
    //   if (combo.first[0] == "/" || combo.first[0] == "-") continue;
    //   final withOp = combo
    //       .map((pair) =>
    //           (pair[1] as Set<String>).map((b) => "${pair[0]}$b").toSet())
    //       .toList();
    //   withOp[0] = combo[0][1];

    //   var results = [...withOp[0]];

    //   for (final nextSimilars in withOp.skip(1)) {
    //     final nextRes = <String>[];
    //     for (final similar in nextSimilars) {
    //       for (var res in results) {
    //         nextRes.add("$res$similar");
    //       }
    //     }
    //     results = nextRes;
    //   }
    //   res.addAll(results);
    // }

    return res;
  }

  Set<String> _flatten(List<Set<String>> binOp, List<String> operations) {
    canBeFlatten(s) => s[0] == '(';

    final asociateBinOp = binOp
        .map((b) => b.any(canBeFlatten) ? b : b.where(canBeFlatten).toList());
    for (var i = 1; i < binOp.length - 1; i++) {
      final prev = binOp[i - 1];
      final curr = binOp[i];
      final next = binOp[i + 1];
      final prevOp = operations[i - 1];
      final nextOp = operations[i];
      for (var prevBinOp in prev) {
        for (var currBinOp in curr) {
          for (var nextBinOp in next) {
            if (canBeFlatten(curr)) {
              final op = <Set<String>>[
                {currBinOp}
              ];
              currBinOp = _flatten(op, []).single; // can faild! __check__
            }
            if (prevOp == '-') {}
          }
        }
      }
    }
    return {};
  }

  List<List<dynamic>> _combinations(List<dynamic> collection) {
    if (collection.length == 1) return [collection];
    final res = <List<dynamic>>[];
    for (var element in collection) {
      final removeItemCollection = [...collection];
      removeItemCollection.remove(element);
      res.addAll(
        _combinations(removeItemCollection).map(
          (r) => [element, ...r],
        ),
      );
    }
    return res;
  }

  Set<String> _genSimilarUnaryOp() {
    if (unaryOp.contains(_lexer.peek().tag)) {
      final op = _lexer.nextToken().value;
      final unaryExpr = _genSimilarUnaryOp();
      return unaryExpr.map((e) => "$op$unaryExpr").toSet();
    } else {
      final factor = _genSimilarFactor();
      return factor;
    }
  }

  Set<String> _genSimilarFactor() {
    var peek = _lexer.peek();
    if (peek.tag == TokenTag.LPAR) {
      _lexer.nextToken();
      final expr = _genSimilar();
      _lexer.nextToken();
      return expr.map((e) => "($e)").toSet();
    }
    if (peek.tag == TokenTag.ID) {
      final callOrId = _genSimilarCallOrId();
      return callOrId;
    }
    if (peek.tag == TokenTag.NUMCONST) {
      final numconst = _lexer.nextToken().value;
      return {numconst};
    }
    throw Exception("Expected invalid validation");
  }

  Set<String> _genSimilarCallOrId() {
    final identifier = _lexer.nextToken().value;
    if (_isFunctionName(identifier)) {
      _lexer.nextToken();
      var args = <String>{};
      if (_lexer.peek().tag != TokenTag.RPAR) {
        args = _genSimilarArgs();
      }

      _lexer.nextToken();
      return args.map((e) => "$identifier($e)").toSet();
    }
    return {identifier};
  }

  Set<String> _genSimilarArgs() {
    final args = _genSimilar();
    while (_lexer.peek().tag == TokenTag.COMMA) {
      _lexer.nextToken();
      args.addAll(_genSimilar());
    }
    return args;
  }
}
