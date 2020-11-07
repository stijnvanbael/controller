typedef PropertyGetter<E> = dynamic Function(E entity);

abstract class PropertyValidator<E> {
  List<ValidationError> validate(E entity, String propertyName, dynamic propertyValue);
}

class CompositePropertyValidator<E> {
  final String propertyName;
  final List<PropertyValidator<E>> validators;
  final PropertyGetter<E> getter;

  CompositePropertyValidator(this.propertyName, this.validators, this.getter);

  List<ValidationError> validate(E entity) =>
      validators.expand((validator) => validator.validate(entity, propertyName, getter(entity))).toList();
}

class EntityValidator<E> {
  final List<CompositePropertyValidator<E>> propertyValidators;

  EntityValidator(this.propertyValidators);

  List<ValidationError> validate(E entity) =>
      propertyValidators.expand((validator) => validator.validate(entity)).toList();
}

class ValidationError {
  final String key;

  ValidationError(this.key);
}
