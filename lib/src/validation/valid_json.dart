import 'dart:async';
import 'dart:convert';

import '../../controller.dart';
import 'common.dart';

const validJson = ValidJson();

class ValidJson extends Validator {
  const ValidJson();

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    if (propertyValue != null &&
        propertyValue is String &&
        propertyValue.isNotEmpty) {
      try {
        jsonDecode(propertyValue);
      } on FormatException catch (e) {
        return [ValidJsonError(propertyName, e.message)];
      }
    }
    return [];
  }

  @override
  FutureOr<List<ValidationError>> validateJson(
      document, String propertyName, dynamic jsonValue) {
    return [];
  }
}

class ValidJsonError extends ValidationError {
  final String propertyName;
  final String message;

  ValidJsonError(this.propertyName, this.message) : super('validJson');

  @override
  String toString() => 'Invalid JSON in $propertyName ($message).';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'message': toString(),
      };
}
