abstract class Expression {
  int get cost;
  String toSimpleString();
  bool brakets = false;

  @override
  int get hashCode => toSimpleString().hashCode;
}
