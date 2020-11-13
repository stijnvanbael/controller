typedef PropertyGetter<E> = dynamic Function(E entity);
typedef Expression<C> = C Function();

const validatable = Validatable();

class Validatable {
  const Validatable();
}

abstract class PropertyValidator {
  const PropertyValidator();

  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue);

  List<ValidationError> validate(String propertyName, dynamic propertyValue) =>
      validateProperty(null, propertyName, propertyValue);
}

class CompositePropertyValidator extends PropertyValidator {
  final List<PropertyValidator> validators;

  const CompositePropertyValidator(this.validators);

  @override
  List<ValidationError> validateProperty(
          dynamic entity, String propertyName, propertyValue) =>
      validators
          .expand((validator) =>
              validator.validateProperty(entity, propertyName, propertyValue))
          .toList();
}

class EntityPropertyValidator extends CompositePropertyValidator {
  final String propertyName;
  final PropertyGetter getter;

  EntityPropertyValidator(
      this.propertyName, List<PropertyValidator> validators, this.getter)
      : super(validators);

  @override
  List<ValidationError> validateProperty(dynamic entity,
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
  List<ValidationError> validateProperty(
          dynamic entity, String propertyName, dynamic propertyValue) =>
      propertyValidators
          .expand((validator) =>
              validator.validateProperty(propertyValue, propertyName))
          .toList();

  List<ValidationError> validateEntity(dynamic entity) => propertyValidators
      .expand((validator) => validator.validateProperty(entity))
      .toList();
}

class ValidationError {
  final String key;

  ValidationError(this.key);

  Map<String, dynamic> toJson() => {'key': key};
}
