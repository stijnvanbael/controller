import 'dart:async';

import 'package:controller/controller.dart';

class IterableValidator extends Validator {
  final Validator elementValidator;

  const IterableValidator(this.elementValidator);

  @override
  FutureOr<List<ValidationError>> validateJson(
      dynamic document, String propertyName, dynamic jsonValue) async {
    var errors = <ValidationError>[];
    if (jsonValue is List) {
      var index = 0;
      for (var element in jsonValue) {
        errors.addAll(await elementValidator.validateJson(
            document, '$propertyName[$index]', element));
      }
    } else {
      errors.add(ListError(propertyName));
    }
    return errors;
  }

  @override
  FutureOr<List<ValidationError>> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) async {
    var errors = <ValidationError>[];
    var index = 0;
    for (var element in propertyValue) {
      errors.addAll(await elementValidator.validateProperty(
          propertyValue, '$propertyName[$index]', element));
    }
    return errors;
  }
}

class ListError extends ValidationError {
  final String propertyName;

  ListError(this.propertyName) : super('list');

  @override
  String toString() => 'The value for $propertyName must be a list.';

  @override
  Map<String, dynamic> toJson() => {
    'key': key,
    'propertyName': propertyName,
    'message': toString(),
  };
}
