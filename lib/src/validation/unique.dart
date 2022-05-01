import 'dart:async';

import '../../controller.dart';

typedef ExistsPredicate<T> = FutureOr<bool> Function(T);

class Unique<T> extends Validator {
  final ExistsPredicate<T> existsPredicate;

  const Unique(this.existsPredicate);

  @override
  FutureOr<List<ValidationError>> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) async {
    if (propertyValue != null &&
        propertyValue != '' &&
        await existsPredicate(propertyValue)) {
      return [UniqueError(propertyName, propertyValue)];
    }
    return [];
  }
}

class UniqueError extends ValidationError {
  final String propertyName;
  final dynamic propertyValue;

  UniqueError(this.propertyName, this.propertyValue) : super('unique');

  @override
  String toString() =>
      'Expected a unique value for $propertyName, but value "$propertyValue" already exists.';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'propertyValue': propertyValue,
        'message': toString(),
      };
}
