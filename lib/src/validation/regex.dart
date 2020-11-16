import '../../controller.dart';

class Regex extends PropertyValidator {
  final String pattern;
  final String name;

  const Regex(this.pattern, this.name);

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, propertyValue) {
    if (propertyValue != null &&
        !RegExp(pattern).hasMatch(propertyValue.toString())) {
      return [RegexError(name, propertyName, propertyValue)];
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
      'Expected a valid $type for $propertyName , but found "$propertyValue".';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'type': type,
        'propertyName': propertyName,
        'propertyValue': propertyValue,
        'message': toString(),
      };
}
