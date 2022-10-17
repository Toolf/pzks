import 'package:pzks/lexer.dart';

List<Token> tokenize(lexer) {
  final tokens = <Token>[];
  while (lexer.peek().tag != TokenTag.EOF) {
    final token = lexer.nextToken();
    tokens.add(token);
  }
  return tokens;
}
