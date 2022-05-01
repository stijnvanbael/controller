import '../../controller.dart';

var _minimum = 'minimum';
var _maximum = 'maximum';

class Min<C extends Comparable> extends Validator {
  final Expression<C>? _expression;
  final C? _value;
  final bool inclusive;

  const Min.expression(this._expression, {this.inclusive = true})
      : _value = null;

  const Min(this._value, {this.inclusive = true}) : _expression = null;

  C _evaluate(dynamic entity) => _value ?? _expression! (entity);

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    var convertedValue = convert<C>(propertyValue);
    var value = _evaluate(entity);
    if (convertedValue != null &&
        (inclusive ? convertedValue < value : convertedValue <= value)) {
      return [
        ComparisonError(
          key: _minimum,
          propertyName: propertyName,
          propertyValue: propertyValue,
          limit: value,
          inclusive: inclusive,
        )
      ];
    }
    return [];
  }
}

class Max<C extends Comparable> extends Validator {
  final Expression<C>? _expression;
  final C? _value;
  final bool inclusive;

  const Max.expression(this._expression, {this.inclusive = true})
      : _value = null;

  const Max(this._value, {this.inclusive = true}) : _expression = null;

  C _evaluate(dynamic entity) => _value ?? _expression! (entity);

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    var convertedValue = convert<C>(propertyValue);
    var value = _evaluate(entity);
    if (convertedValue != null &&
        (inclusive ? convertedValue > value : convertedValue >= value)) {
      return [
        ComparisonError(
          key: _maximum,
          propertyName: propertyName,
          propertyValue: propertyValue,
          limit: value,
          inclusive: inclusive,
        )
      ];
    }
    return [];
  }
}

class ComparisonError extends ValidationError {
  final String propertyName;
  final dynamic propertyValue;
  final dynamic limit;
  final bool inclusive;

  ComparisonError({
    required String key,
    required this.propertyName,
    required this.propertyValue,
    required this.limit,
    required this.inclusive,
  }) : super(key);

  @override
  String toString() => 'Expected a value for $propertyName '
      '${inclusive ? key == _minimum ? '≥' : '≤' : key == _minimum ? '>' : '<'}'
      ' $limit, found "$propertyValue".';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'propertyValue': propertyValue.toString(),
        key: limit.toString(),
        'inclusive': inclusive,
        'message': toString(),
      };
}

extension Operators<T> on Comparable<T> {
  bool operator <(T other) => compareTo(other) < 0;

  bool operator <=(T other) => compareTo(other) <= 0;

  bool operator >(T other) => compareTo(other) > 0;

  bool operator >=(T other) => compareTo(other) >= 0;
}
