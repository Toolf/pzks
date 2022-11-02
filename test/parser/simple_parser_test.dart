import 'package:pzks/parser.dart';
import 'package:test/test.dart';

void main() {
  group("Error on the start of expression", () {
    test('Expression cannot start with close braket', () {
      // arrange
      final expression = ")5+3";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError("Expected an identifier or expression", 0, 0, 0, 1),
      ];
      expect(parser.errors, expectedErrors);
    });

    test("Expression cannot start with '*'", () {
      // arrange
      final expression = "*5+3";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError("Expected an identifier or expression", 0, 0, 0, 1),
      ];
      expect(parser.errors, expectedErrors);
    });

    test("Expression cannot start with '/'", () {
      // arrange
      final expression = "/5+3";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError("Expected an identifier or expression", 0, 0, 0, 1),
      ];
      expect(parser.errors, expectedErrors);
    });
  });

  group("Invalid naming or function name or constant", () {
    test('Invalid invoke function', () {
      // arrange
      final expression = "test(arg1, arg2)";
      final functions = <FunctionDeclaration>[];
      // act
      final parser = Parser(expression, functions);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError(
          "The expression doesn't evaluate to a function, so it can't be invoked",
          0,
          4,
          0,
          5,
        ),
        SyntaxError("Expect operation", 0, 4, 0, 5),
        SyntaxError("Expected ')'", 0, 9, 0, 15),
      ];
      expect(parser.errors, expectedErrors);
    });

    test('Valid invoke function', () {
      // arrange
      final expression = "test(arg1, arg2)";
      final functions = [
        FunctionDeclaration(
          "test",
          [ArgDeclaration(), ArgDeclaration()],
        ),
      ];
      // act
      final parser = Parser(expression, functions);
      parser.validate();
      // assert
      final expectedErrors = [];
      expect(parser.errors, expectedErrors);
    });

    test('Invalid variable naming', () {
      // arrange
      final expression = "3args";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError(
          "Expect operation",
          0,
          1,
          0,
          2,
        ),
      ];
      expect(parser.errors, expectedErrors);
    });

    test('Invalid constant', () {
      // arrange
      final expression = "3.14.14";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError(
          "Expect operation",
          0,
          4,
          0,
          5,
        ),
        SyntaxError(
          "Expected '(' or identity or constant",
          0,
          4,
          0,
          5,
        ),
      ];
      expect(parser.errors, expectedErrors);
    });
  });

  group("Mistake in the end of expression", () {
    test("Invalid \'(\' in the end", () {
      // arrange
      final expression = "(a+3-7*2+2";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [SyntaxError("Expected ')'", 0, 10, 0, 10)];
      expect(parser.errors, expectedErrors);
    });
  });

  group("Operator mistakes", () {
    test('Double operator', () {
      // arrange
      final expression = "7**7";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError("Expected '(' or identifier or constant", 0, 2, 0, 3)
      ];
      expect(parser.errors, expectedErrors);
    });

    test('No operators between brackets', () {
      // arrange
      final expression = "(7)(7)";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [SyntaxError("Expected operation", 0, 3, 0, 4)];
      expect(parser.errors, expectedErrors);
    });

    test('Operation after open bracket', () {
      // arrange
      final expression = "(*3)";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError("Expected '(' or identifier or constant", 0, 1, 0, 2)
      ];
      expect(parser.errors, expectedErrors);
    });
  });

  group("Brackets mistakes", () {
    test('Invalid brackets count', () {
      // arrange
      final expression = "(b";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError("Expected ')'", 0, 2, 0, 2),
      ];
      expect(parser.errors, expectedErrors);
    });

    test('Empty brackets', () {
      // arrange
      final expression = "()";
      // act
      final parser = Parser(expression);
      parser.validate();
      // assert
      final expectedErrors = [
        SyntaxError("Expected '(' or identifier or constant", 0, 1, 0, 2),
        SyntaxError("Expected ')'", 0, 2, 0, 2)
      ];
      expect(parser.errors, expectedErrors);
    });
  });
  group("Binary operation invarsion for best tree height", () {
    test('a-(b+c)', () {
      // arrange
      final expression = "a-(b+c)";
      // act
      final parser = Parser(expression);
      final expr = parser.parse();
      // assert
      final expectedExpression = "a-(b+c)";
      expect(expr.toSimpleString(), expectedExpression);
    });

    test('a-b-c-d', () {
      // arrange
      final expression = "a-b-c-d";
      // act
      final parser = Parser(expression);
      final expr = parser.parse();
      // assert
      final expectedExpression = "a-b-(c+d)";
      expect(expr.toSimpleString(), expectedExpression);
    });

    test('a-b-(c-d)', () {
      // arrange
      final expression = "a-b-(c-d)";
      // act
      final parser = Parser(expression);
      final expr = parser.parse();
      // assert
      final expectedExpression = "a-b-(c-d)";
      expect(expr.toSimpleString(), expectedExpression);
    });

    test('a/b/c/d/e/f/g/h', () {
      // arrange
      final expression = "a/b/c/d/e/f/g/h";
      // act
      final parser = Parser(expression);
      final expr = parser.parse();
      // assert
      final expectedExpression = "a/b/(c*d)/(e*f*g*h)";
      expect(expr.toSimpleString(), expectedExpression);
    });
  });
}
