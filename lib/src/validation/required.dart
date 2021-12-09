import 'dart:async';

import '../../controller.dart';
import 'common.dart';

const required = Required();

bool always(dynamic entity) => true;

class Required extends Validator {
  const Required();

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    if (propertyValue == null ||
        (propertyValue is String && propertyValue.isEmpty)) {
      return [RequiredError(propertyName)];
    }
    return [];
  }

  @override
  FutureOr<List<ValidationError>> validateJson(
      entity, String propertyName, dynamic jsonValue) {
    if (jsonValue == null || (jsonValue is String && jsonValue.isEmpty)) {
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

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'message': toString(),
      };
}
