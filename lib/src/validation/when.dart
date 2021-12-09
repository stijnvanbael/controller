import 'dart:async';

import '../../controller.dart';

class When extends Validator {
  final Predicate predicate;
  final Validator delegate;

  const When(this.predicate, this.delegate);

  @override
  FutureOr<List<ValidationError>> validateProperty(
    dynamic entity,
    String propertyName,
    propertyValue,
  ) =>
      predicate(entity)
          ? delegate.validateProperty(entity, propertyName, propertyValue)
          : [];
}
