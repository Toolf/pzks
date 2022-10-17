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

  static const sumOp = ['+', '-'];
  static const mulOp = ['*', '/'];
  static const unaryOp = ['+', '-'];
  final errors = [];

  final List<FunctionDeclaration> functions;

  Parser(this.code, [this.functions = const []]) : _lexer = Lexer(code);

  parse() {
    final peekBefore = _lexer.peek();
    final expr = _parseExpression();
    final peekAfter = _lexer.peek();
    if (peekAfter.tag != TokenTag.EOF) {
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
      parse();
    }
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

  _parseExpression() {
    final l = _parseMulExpression();
    while (sumOp.contains(_lexer.peek().value)) {
      final op = _lexer.nextToken();
      final r = _parseMulExpression();
    }
  }

  _parseMulExpression() {
    final l = _parseUnaryExpression();
    while (mulOp.contains(_lexer.peek().value)) {
      final op = _lexer.nextToken();
      final r = _parseUnaryExpression();
    }
  }

  _parseUnaryExpression() {
    if (unaryOp.contains(_lexer.peek().value)) {
      final op = _lexer.nextToken();
      final unaryExpr = _parseUnaryExpression();
    } else {
      _expected([TokenTag.LPAR, TokenTag.ID, TokenTag.NUMCONST]);
      final factor = _parseFactor();
    }
  }

  _parseFactor() {
    var peek = _lexer.peek();
    if (peek.tag == TokenTag.LPAR) {
      _lexer.nextToken();
      final expr = _parseExpression();
      _expected([TokenTag.RPAR]);
      _lexer.nextToken();
      return expr;
    }
    if (peek.tag == TokenTag.ID) {
      final callOrId = _parseCallOrId();
      return callOrId;
    }
    if (peek.tag == TokenTag.NUMCONST) {
      final numconst = _lexer.nextToken();
      return numconst;
    }

    // bad factor
  }

  _parseCallOrId() {
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
        final args = _parseArgs();
        final endPeek = _lexer.peek();
        // if (args.length !=
        //     functions.firstWhere((f) => id.value == f.name).args.length) {
        //   errors.add(
        //     SyntaxError(
        //       "Invalid arguments count",
        //       peek.row,
        //       peek.col,
        //       endPeek.row,
        //       endPeek.col + endPeek.value.length,
        //     ),
        //   );
        // }
      }

      _expected([TokenTag.RPAR]);
      _lexer.nextToken();
    }
  }

  _parseArgs() {
    final expr = _parseExpression();
    while (_lexer.peek().tag == TokenTag.COMMA) {
      _lexer.nextToken();
      final args = _parseExpression();
    }
  }
}
