import 'dart:async';

typedef PropertyGetter<E> = dynamic Function(E entity);
typedef Expression<C> = C Function(dynamic entity);

const validatable = Validatable();

class Validatable {
  const Validatable();
}

abstract class PropertyValidator {
  const PropertyValidator();

  FutureOr<List<ValidationError>> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue);

  FutureOr<List<ValidationError>> validate(
          String propertyName, dynamic propertyValue) =>
      validateProperty(null, propertyName, propertyValue);
}

class CompositePropertyValidator extends PropertyValidator {
  final List<PropertyValidator> validators;

  const CompositePropertyValidator(this.validators);

  @override
  FutureOr<List<ValidationError>> validateProperty(
      dynamic entity, String propertyName, propertyValue) async {
    var errors = <ValidationError>[];
    for (var validator in validators) {
      errors.addAll(await validator.validateProperty(
          entity, propertyName, propertyValue));
    }
    return errors;
  }
}

class EntityPropertyValidator extends CompositePropertyValidator {
  final String propertyName;
  final PropertyGetter getter;

  EntityPropertyValidator(
      this.propertyName, List<PropertyValidator> validators, this.getter)
      : super(validators);

  @override
  FutureOr<List<ValidationError>> validateProperty(dynamic entity,
          [String /*?*/ parentProperty, dynamic /*?*/ propertyValue]) =>
      super.validateProperty(
          entity,
          parentProperty != null
              ? '$parentProperty.$propertyName'
              : propertyName,
          getter(entity));
}

class EntityValidator extends PropertyValidator {
  final List<EntityPropertyValidator> propertyValidators;

  EntityValidator(this.propertyValidators);

  @override
  FutureOr<List<ValidationError>> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) async {
    var errors = <ValidationError>[];
    for (var validator in propertyValidators) {
      errors.addAll(
          await validator.validateProperty(propertyValue, propertyName));
    }
    return errors;
  }

  FutureOr<List<ValidationError>> validateEntity(dynamic entity) async {
    var errors = <ValidationError>[];
    for (var validator in propertyValidators) {
      errors.addAll(await validator.validateProperty(entity));
    }
    return errors;
  }
}

class ValidationError {
  final String key;

  ValidationError(this.key);

  Map<String, dynamic> toJson() => {'key': key};
}
