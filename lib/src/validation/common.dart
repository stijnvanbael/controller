typedef PropertyGetter<E> = dynamic Function(E entity);

abstract class PropertyValidator {
  List<ValidationError> validate(dynamic entity, String propertyName, dynamic propertyValue);
}

class CompositePropertyValidator {
  final String propertyName;
  final List<PropertyValidator> validators;
  final PropertyGetter getter;

  CompositePropertyValidator(this.propertyName, this.validators, this.getter);

  List<ValidationError> validate(dynamic entity) =>
      validators.expand((validator) => validator.validate(entity, propertyName, getter(entity))).toList();
}

class EntityValidator {
  final List<CompositePropertyValidator> propertyValidators;

  EntityValidator(this.propertyValidators);

  List<ValidationError> validate(dynamic entity) =>
      propertyValidators.expand((validator) => validator.validate(entity)).toList();
}

class ValidationError {
  final String key;

  ValidationError(this.key);
}
