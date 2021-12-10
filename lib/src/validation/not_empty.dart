import 'dart:async';

import '../../controller.dart';
import 'common.dart';

const notEmpty = NotEmpty();

bool always(dynamic entity) => true;

class NotEmpty extends Validator {
  const NotEmpty();

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    if (propertyValue != null &&
        (propertyValue is String && propertyValue.isEmpty)) {
      return [NotEmptyError(propertyName)];
    }
    return [];
  }

  @override
  FutureOr<List<ValidationError>> validateJson(
      entity, String propertyName, dynamic jsonValue) {
    if (jsonValue != null && (jsonValue is String && jsonValue.isEmpty)) {
      return [NotEmptyError(propertyName)];
    }
    return [];
  }
}

class NotEmptyError extends ValidationError {
  final String propertyName;

  NotEmptyError(this.propertyName) : super('notEmpty');

  @override
  String toString() => 'A value for $propertyName is cannot be empty.';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'message': toString(),
      };
}
