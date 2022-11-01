import 'package:pzks/ast/binary_operation.dart';
import 'package:pzks/ast/numconst.dart';
import 'package:pzks/ast/unary_operation.dart';

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

  Parser(this.code, [this.functions = const []]) : _lexer = Lexer(code);

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
    return _normalizeBinaryTree(binOp as BinaryOperation);
  }

  Expression _buildBinaryTree(
    List<Expression> binaryOperations,
    List<String> operations,
  ) {
    if (binaryOperations.length == 1) return binaryOperations[0];
    final lSize = binaryOperations.length ~/ 2;
    return BinaryOperation(
      operations[lSize - 1],
      _buildBinaryTree(
        binaryOperations.sublist(0, lSize),
        operations.sublist(0, lSize - 1),
      ),
      _buildBinaryTree(
        binaryOperations.sublist(lSize),
        operations.sublist(lSize),
      ),
    );
  }

  BinaryOperation _normalizeBinaryTree(BinaryOperation binayOp) {
    var left = binayOp.left;
    var right = binayOp.right;
    if (left is BinaryOperation) {
      left = _normalizeBinaryTree(left);
    }
    if (right is BinaryOperation) {
      right = _normalizeBinaryTree(right);
      if (binayOp.operation == "/" && right.operation == "/") {
        right = BinaryOperation("*", right.left, right.right);
      }
      if (binayOp.operation == "-" && right.operation == "-") {
        right = BinaryOperation("+", right.left, right.right);
      }
    }
    return BinaryOperation(binayOp.operation, left, right);
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
}
