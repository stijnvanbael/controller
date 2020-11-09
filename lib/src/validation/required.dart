import 'common.dart';

class RequiredValidator implements PropertyValidator {
  static final RequiredValidator instance = RequiredValidator();

  @override
  List<ValidationError> validateProperty(dynamic entity, String propertyName, dynamic propertyValue) {
    if (propertyValue == null || (propertyValue is String && propertyValue.isEmpty)) {
      return [RequiredError(propertyName)];
    }
    return [];
  }
}

class RequiredError extends ValidationError {
  final String propertyName;

  RequiredError(this.propertyName) : super('required');

  @override
  String toString() => 'A value for $propertyName is required.';

  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'message': toString(),
      };
}
