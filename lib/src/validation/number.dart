import 'package:controller/controller.dart';

import 'common.dart';

const NumberValidator<int> integer =
    NumberValidator._(int.tryParse, _createIntegerError);

const NumberValidator<double> decimal =
    NumberValidator._(double.tryParse, _createDecimalError);

const NumberValidator<num> number =
    NumberValidator._(num.tryParse, _createNumberError);

class NumberValidator<N extends num> extends PropertyValidator {
  final N Function(String) _parser;
  final NumberError Function(String, dynamic) _errorBuilder;

  const NumberValidator._(this._parser, this._errorBuilder);

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    if (propertyValue != null && _parser(propertyValue) == null) {
      return [_errorBuilder(propertyName, propertyValue)];
    }
    return [];
  }
}

NumberError _createIntegerError(name, value) =>
    NumberError.integer(name, value);

NumberError _createDecimalError(name, value) =>
    NumberError.decimal(name, value);

NumberError _createNumberError(name, value) => NumberError.number(name, value);

class NumberError extends ValidationError {
  final String propertyName;
  final dynamic propertyValue;

  NumberError.integer(this.propertyName, this.propertyValue) : super('integer');

  NumberError.decimal(this.propertyName, this.propertyValue) : super('decimal');

  NumberError.number(this.propertyName, this.propertyValue) : super('number');

  @override
  String toString() =>
      'Expected $key value for property $propertyName, but found "$propertyValue"';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'propertyValue': propertyValue,
        'message': toString(),
      };
}
