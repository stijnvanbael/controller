import 'common.dart';

/// Annotate a request parameter or the property of a request body
/// to validate its length is within the specified range.
class Length extends Validator {
  final int min;
  final int? max;

  const Length({this.min = 0, this.max});

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    if (propertyValue != null) {
      if (propertyValue is String) {
        return _validateString(propertyValue, propertyName);
      } else if (propertyValue is Iterable) {
        return _validateIterable(propertyValue, propertyName);
      } else if (propertyValue is Map) {
        return _validateMap(propertyValue, propertyName);
      } else {
        throw "Don't know how validate the length of ${propertyValue.runtimeType}";
      }
    }
    return [];
  }

  List<ValidationError> _validateString(
      String propertyValue, String propertyName) {
    if (propertyValue.length < min ||
        (max != null && propertyValue.length > max!)) {
      return [LengthError(propertyName, min, max, propertyValue.length)];
    }
    return [];
  }

  List<ValidationError> _validateIterable(
      Iterable propertyValue, String propertyName) {
    if (propertyValue.length < min ||
        (max != null && propertyValue.length > max!)) {
      return [LengthError(propertyName, min, max, propertyValue.length)];
    }
    return [];
  }

  List<ValidationError> _validateMap(Map propertyValue, String propertyName) {
    if (propertyValue.length < min ||
        (max != null && propertyValue.length > max!)) {
      return [LengthError(propertyName, min, max, propertyValue.length)];
    }
    return [];
  }
}

class LengthError extends ValidationError {
  final String propertyName;
  final int min;
  final int? max;
  final int actual;

  LengthError(this.propertyName, this.min, this.max, this.actual)
      : super('length');

  @override
  String toString() =>
      'The length of the value for $propertyName should be between $min and $max, actual: $actual.';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'min': min,
        'max': max,
        'actual': actual,
        'message': toString(),
      };
}
