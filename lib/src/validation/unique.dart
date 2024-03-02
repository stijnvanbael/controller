import 'dart:async';

import '../../controller.dart';

typedef ExistsPredicate<T> = FutureOr<bool> Function(T);

/// Annotate a request parameter or the property of a request body
/// to validate its value is unique.
class Unique<T> extends Validator {
  /// A predicate used to check whether the value already exists
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
        'propertyValue': propertyValue.toString(),
        'message': toString(),
      };
}
