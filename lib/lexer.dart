// ignore_for_file: constant_identifier_names

import 'helper.dart';

enum TokenTag {
  LPAR, // '('
  RPAR, // ')'
  DOT, // '.'

  PLUS, // '+'
  MINUS, // '-'
  STAR, // '*'
  SLASH, // '/'

  NUMCONST, // 154.57
  ID, // 'i3'

  COMMA, // ','

  UNKNOWN, // '???'

  EOF, // end of file/code
}

extension TokenTagToString on TokenTag {
  String get value {
    switch (this) {
      case TokenTag.LPAR:
        return "'('";
      case TokenTag.RPAR:
        return "')'";
      case TokenTag.DOT:
        return "'.'";
      case TokenTag.PLUS:
        return "'+'";
      case TokenTag.MINUS:
        return "'-'";
      case TokenTag.STAR:
        return "'*'";
      case TokenTag.SLASH:
        return "'/'";
      case TokenTag.COMMA:
        return "','";
      case TokenTag.ID:
        return "identifier";
      case TokenTag.NUMCONST:
        return "constant";
      case TokenTag.UNKNOWN:
      default:
        return "???";
    }
  }
}

const Map<String, TokenTag> TokenTypes = {
  "(": TokenTag.LPAR,
  ")": TokenTag.RPAR,
  "+": TokenTag.PLUS,
  "-": TokenTag.MINUS,
  "*": TokenTag.STAR,
  "/": TokenTag.SLASH,
  ',': TokenTag.COMMA,
  ".": TokenTag.DOT,
};

const whiteList = {
  ' ',
  '\t',
  '\n',
};

class Token {
  final TokenTag tag;
  final String value;
  final int row;
  final int col;

  Token(
    this.tag,
    this.value,
    this.row,
    this.col,
  );

  @override
  String toString() {
    return "tag=$tag, value='$value', row=$row, col=$col";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Token &&
        other.tag == tag &&
        other.value == value &&
        other.row == row &&
        other.col == col;
  }

  @override
  int get hashCode => tag.hashCode + value.hashCode + row + col;
}

class LexerException {
  final String message;

  LexerException(this.message);
}

class Lexer {
  int row = 0;
  int col = 0;
  int index = 0;
  final String code;

  Lexer(this.code);

  // Return next token without change internal state
  Token peek() {
    // save state
    final savedRow = row;
    final savedCol = col;
    final savedIndex = index;
    final t = nextToken(); // can change state
    // reload state
    row = savedRow;
    col = savedCol;
    index = savedIndex;
    return t;
  }

  Token nextToken() {
    if (code.length == index) {
      return Token(TokenTag.EOF, "", row, col);
    }
    // skip whitelist
    while (whiteList.contains(code[index])) {
      if (code[index] == '\n') {
        row++;
        col = 0;
      } else {
        col++;
      }
      index++;
      if (code.length == index) {
        return Token(TokenTag.EOF, "", row, col);
      }
    }

    // const number
    if (isDigit(code[index])) {
      Token t = _getNumber();
      return t;
    }

    // id (variable)
    if (isLetter(code[index])) {
      Token t = _getVariable();
      return t;
    }

    // known other tokens
    final tokenNames = TokenTypes.keys.toList();
    tokenNames.sort((a, b) => a.length - b.length);
    for (final tokenName in tokenNames) {
      if (code.substring(index, index + tokenName.length) == tokenName) {
        final t = Token(TokenTypes[tokenName]!, tokenName, row, col);
        index += tokenName.length;
        col += tokenName.length;
        return t;
      }
    }

    // Unknown token
    final t = Token(TokenTag.UNKNOWN, code[index], row, col);
    index++;
    col++;
    return t;
  }

  // Used by nextToken
  // Return next number token
  // Throw Exception("Cannot detect number token. Invalid lexer code") if was called with invalid state (start by not number).
  // Throw LexerException("Bad float number, double dots in number").
  // !Change lexer state
  _getNumber() {
    if (!isDigit(code[index])) {
      throw Exception(
        "Cannot detect number token. Invalid lexer code.",
      );
    }
    bool floatNumber = false;
    final startIndex = index;
    final startRow = row;
    final startCol = col;
    while (
        index < code.length && (isDigit(code[index]) || code[index] == '.')) {
      if (code[index] == '.') {
        if (floatNumber) {
          break;
          // throw LexerException("Bad float number, double dots in number");
        }
        floatNumber = true;
      }
      index++;
      col++;
    }

    final value = code.substring(startIndex, index);
    return Token(TokenTag.NUMCONST, value, startRow, startCol);
  }

  // Used by nextToken
  // Return next variable token
  // Throw Exception("Cannot detect variable token. Inbalid lexer code") if was called with invalid state (start by not number).
  // !Change lexer state
  _getVariable() {
    if (!isLetter(code[index])) {
      throw Exception(
        "Cannot detect variable token. Inbalid lexer code",
      );
    }
    final startIndex = index;
    final startRow = row;
    final startCol = col;
    while (index < code.length && isLetDig(code[index])) {
      index++;
      col++;
    }
    final value = code.substring(startIndex, index);
    return Token(TokenTag.ID, value, startRow, startCol);
  }
}
