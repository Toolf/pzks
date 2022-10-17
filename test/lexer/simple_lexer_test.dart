import 'dart:math';

import 'package:pzks/pzks.dart';
import 'package:test/test.dart';

import 'helper.dart';

void main() {
  test('test#1 simple lexer test', () {
    // arrange
    final expression = "a+91*b()-/яs";
    // act
    final lexer = Lexer(expression);
    final tokens = tokenize(lexer);
    // assert
    final expectedTokens = [
      Token(TokenTag.ID, "a", 0, 0),
      Token(TokenTag.PLUS, "+", 0, 1),
      Token(TokenTag.NUMCONST, "91", 0, 2),
      Token(TokenTag.STAR, "*", 0, 4),
      Token(TokenTag.ID, "b", 0, 5),
      Token(TokenTag.LPAR, "(", 0, 6),
      Token(TokenTag.RPAR, ")", 0, 7),
      Token(TokenTag.MINUS, "-", 0, 8),
      Token(TokenTag.SLASH, "/", 0, 9),
      Token(TokenTag.UNKNOWN, "я", 0, 10),
      Token(TokenTag.ID, "s", 0, 11),
    ];

    expect(tokens, expectedTokens);
  });

  test('test#2 sin(b3c', () {
    // arrange
    final expression = "sin(b3c";
    // act
    final lexer = Lexer(expression);
    // assert
    expect(lexer.peek(), Token(TokenTag.ID, "sin", 0, 0));
    expect(lexer.nextToken(), Token(TokenTag.ID, "sin", 0, 0));
    expect(lexer.peek(), Token(TokenTag.LPAR, "(", 0, 3));
    expect(lexer.nextToken(), Token(TokenTag.LPAR, "(", 0, 3));
    expect(lexer.peek(), Token(TokenTag.ID, "b3c", 0, 4));
    expect(lexer.nextToken(), Token(TokenTag.ID, "b3c", 0, 4));
  });
}
