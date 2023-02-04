import '../../controller.dart';

/// Annotate a request parameter or the property of a request body
/// to validate its value satisfies the specified regular expression.
class Regex extends Validator {
  /// A regular expression pattern
  final String pattern;

  /// A type to display in an error message (eg. email, phone number, etc)
  final String type;

  const Regex(this.pattern, this.type);

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, propertyValue) {
    if (propertyValue != null &&
        propertyValue != '' &&
        !RegExp(pattern).hasMatch(propertyValue.toString())) {
      return [RegexError(type, propertyName, propertyValue)];
    }
    return [];
  }
}

class RegexError extends ValidationError {
  final String type;
  final String propertyName;
  final dynamic propertyValue;

  RegexError(this.type, this.propertyName, this.propertyValue) : super('regex');

  @override
  String toString() =>
      'Expected a valid $type for $propertyName, but found "$propertyValue".';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'type': type,
        'propertyName': propertyName,
        'propertyValue': propertyValue,
        'message': toString(),
      };
}
