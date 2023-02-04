import 'dart:async';

import '../../controller.dart';

/// Annotate a request parameter or the property of a request body
/// to apply the wrapped validator conditionally.
class When extends Validator {
  /// The condition when the wrapped validator should be applied
  final Predicate predicate;

  /// The wrapped validator to apply conditionally
  final Validator delegate;

  const When(this.predicate, this.delegate);

  @override
  FutureOr<List<ValidationError>> validateProperty(dynamic entity,
      String propertyName,
      propertyValue,) =>
      predicate(entity)
          ? delegate.validateProperty(entity, propertyName, propertyValue)
          : [];
}
