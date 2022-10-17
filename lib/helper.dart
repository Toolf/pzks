import 'package:pzks/parser.dart';

const digits = '0123456789';
const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

bool isDigit(String char) {
  return digits.contains(char[0]);
}

bool isLetter(String char) {
  return letters.contains(char[0]);
}

bool isLetDig(String char) {
  return isDigit(char) || isLetter(char);
}

String highlight(String code, SyntaxError error) {
  // ignore: prefer_interpolation_to_compose_strings
  return code +
      "\n" +
      " " * (error.fromCol) +
      "^" +
      "~" * (error.toCol - error.fromCol - 1) +
      "\n" +
      " " * (error.fromCol) +
      error.message;
}

String centrize(String str, int len) {
  if (str.length >= len) return str;
  final r = (len - str.length) ~/ 2;
  final l = len - str.length - r;
  return " " * r + str + " " * l;
}
