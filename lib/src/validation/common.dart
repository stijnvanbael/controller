typedef PropertyGetter<E> = dynamic Function(E entity);

abstract class PropertyValidator {
  List<ValidationError> validateProperty(dynamic entity, String propertyName, dynamic propertyValue);
}

class CompositePropertyValidator implements PropertyValidator {
  final String propertyName;
  final List<PropertyValidator> validators;
  final PropertyGetter getter;

  CompositePropertyValidator(this.propertyName, this.validators, this.getter);

  @override
  List<ValidationError> validateProperty(dynamic entity, [String parentProperty, dynamic propertyValue]) => validators
      .expand((validator) => validator.validateProperty(
            entity,
            parentProperty != null ? '$parentProperty.$propertyName' : propertyName,
            getter(entity),
          ))
      .toList();
}

class EntityValidator implements PropertyValidator {
  final List<CompositePropertyValidator> propertyValidators;

  EntityValidator(this.propertyValidators);

  @override
  List<ValidationError> validateProperty(dynamic entity, String propertyName, dynamic propertyValue) =>
      propertyValidators
          .expand((validator) => validator.validateProperty(propertyValue, propertyName))
          .toList();

  List<ValidationError> validateEntity(dynamic entity) =>
      propertyValidators.expand((validator) => validator.validateProperty(entity)).toList();
}

class ValidationError {
  final String key;

  ValidationError(this.key);

  Map<String, dynamic> toJson() => {'key': key};
}
