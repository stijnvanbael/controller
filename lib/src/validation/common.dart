import 'dart:async';

typedef PropertyGetter<E> = dynamic Function(E entity);
typedef Expression<C> = C Function(dynamic entity);

const validatable = Validatable();

/// Annotate a class to enable validation checks on it
class Validatable {
  const Validatable();
}

/// Annotate a request parameter or the property of a request body
/// to validate it.
abstract class Validator {
  const Validator();

  /// Validates the property of a class.
  /// Returns validation errors when the property is not valid according
  /// to this validator.
  /// entity is the enclosing object being validated.
  FutureOr<List<ValidationError>> validateProperty(dynamic entity,
      String propertyName, dynamic propertyValue);

  /// Validates the field of a JSON object.
  /// Returns validation errors when the property is not valid according
  /// to this validator.
  /// document is the enclosing JSON object being validated.
  FutureOr<List<ValidationError>> validateJson(dynamic document,
      String propertyName, dynamic jsonValue) =>
      [];

  /// Validates a request parameter or the entiry body of a request.
  /// Returns validation errors when the property is not valid according
  /// to this validator.
  /// entity is the enclosing object being validated.
  FutureOr<List<ValidationError>> validate(String propertyName,
      dynamic propertyValue) =>
      validateProperty(null, propertyName, propertyValue);
}

/// Verifies all validators supplied via the constructor and aggregates
/// all validation errors.
class CompositeValidator extends Validator {
  final List<Validator> validators;

  const CompositeValidator(this.validators);

  @override
  FutureOr<List<ValidationError>> validateProperty(dynamic entity,
      String propertyName, propertyValue) async {
    var errors = <ValidationError>[];
    for (var validator in validators) {
      errors.addAll(await validator.validateProperty(
          entity, propertyName, propertyValue));
    }
    return errors;
  }

  @override
  FutureOr<List<ValidationError>> validateJson(dynamic document,
      String propertyName, jsonValue) async {
    var errors = <ValidationError>[];
    for (var validator in validators) {
      errors.addAll(
          await validator.validateJson(document, propertyName, jsonValue));
    }
    return errors;
  }
}

/// Validates the property of a class with all validators specified in the
/// constructor.
class PropertyValidator extends CompositeValidator {
  final String name;
  final PropertyGetter propertyGetter;

  PropertyValidator(this.name,
      List<Validator> validators,
      this.propertyGetter,) : super(validators);

  @override
  FutureOr<List<ValidationError>> validateProperty(dynamic entity,
      [String? propertyName, dynamic propertyValue]) =>
      super.validateProperty(
          entity,
          propertyName != null ? '$propertyName.$name' : name,
          propertyGetter(entity));

  @override
  FutureOr<List<ValidationError>> validateJson(dynamic document,
      [String? propertyName, dynamic jsonValue]) {
    final childName = propertyName != null ? '$propertyName.$name' : name;
    if (document != null && document is! Map) {
      return [ObjectError(childName)];
    }
    return super.validateJson(document, childName, document?[name]);
  }
}

/// Validates the properties of an object with the property validators
/// specified in the constructor.
class EntityValidator extends Validator {
  final List<PropertyValidator> propertyValidators;

  EntityValidator(this.propertyValidators);

  @override
  FutureOr<List<ValidationError>> validateProperty(dynamic entity,
      String propertyName, dynamic propertyValue) async {
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

  @override
  FutureOr<List<ValidationError>> validateJson(dynamic document,
      String propertyName, dynamic jsonValue) async {
    var errors = <ValidationError>[];
    for (var validator in propertyValidators) {
      errors.addAll(await validator.validateJson(jsonValue, propertyName));
    }
    return errors;
  }

  FutureOr<List<ValidationError>> validateDocument(dynamic document) async {
    var errors = <ValidationError>[];
    for (var validator in propertyValidators) {
      errors.addAll(await validator.validateJson(document));
    }
    return errors;
  }
}

/// An error created by a validator for an invalid value.
class ValidationError {
  /// Identifies the validator that produced this validation error
  final String key;

  ValidationError(this.key);

  Map<String, dynamic> toJson() => {'key': key};

  @override
  String toString() => key;
}

class ObjectError extends ValidationError {
  final String propertyName;

  ObjectError(this.propertyName) : super('object');

  @override
  String toString() => 'The value for $propertyName must be an object.';

  @override
  Map<String, dynamic> toJson() =>
      {
        'key': key,
        'propertyName': propertyName,
        'message': toString(),
      };
}
