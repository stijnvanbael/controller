import 'dart:async';

typedef PropertyGetter<E> = dynamic Function(E entity);
typedef Expression<C> = C Function(dynamic entity);

const validatable = Validatable();

class Validatable {
  const Validatable();
}

abstract class Validator {
  const Validator();

  FutureOr<List<ValidationError>> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue);

  FutureOr<List<ValidationError>> validateJson(
          dynamic document, String propertyName, dynamic jsonValue) =>
      [];

  FutureOr<List<ValidationError>> validate(
          String propertyName, dynamic propertyValue) =>
      validateProperty(null, propertyName, propertyValue);
}

class CompositeValidator extends Validator {
  final List<Validator> validators;

  const CompositeValidator(this.validators);

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

  @override
  FutureOr<List<ValidationError>> validateJson(
      dynamic entity, String propertyName, jsonValue) async {
    var errors = <ValidationError>[];
    for (var validator in validators) {
      errors.addAll(
          await validator.validateJson(entity, propertyName, jsonValue));
    }
    return errors;
  }
}

class PropertyValidator extends CompositeValidator {
  final String propertyName;
  final PropertyGetter propertyGetter;

  PropertyValidator(
    this.propertyName,
    List<Validator> validators,
    this.propertyGetter,
  ) : super(validators);

  @override
  FutureOr<List<ValidationError>> validateProperty(dynamic entity,
          [String? parentProperty, dynamic propertyValue]) =>
      super.validateProperty(
          entity,
          parentProperty != null
              ? '$parentProperty.$propertyName'
              : propertyName,
          propertyGetter(entity));

  @override
  FutureOr<List<ValidationError>> validateJson(dynamic document,
          [String? parentProperty, dynamic jsonValue]) =>
      super.validateJson(
          document,
          parentProperty != null
              ? '$parentProperty.$propertyName'
              : propertyName,
          document[propertyName]);
}

class EntityValidator extends Validator {
  final List<PropertyValidator> propertyValidators;

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

  @override
  FutureOr<List<ValidationError>> validateJson(
      dynamic entity, String propertyName, dynamic jsonValue) async {
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

class ValidationError {
  final String key;

  ValidationError(this.key);

  Map<String, dynamic> toJson() => {'key': key};

  @override
  String toString() => key;
}
