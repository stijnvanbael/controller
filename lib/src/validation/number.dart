import 'common.dart';

class NumberValidator<N extends num> extends PropertyValidator {
  static final NumberValidator<int> integer = NumberValidator._(
      int.parse, (name, value) => NumberError.integer(name, value));
  static final NumberValidator<double> decimal = NumberValidator._(
      double.parse, (name, value) => NumberError.decimal(name, value));
  static final NumberValidator<num> number = NumberValidator._(
      num.parse, (name, value) => NumberError.number(name, value));

  final N Function(String) _parser;
  final NumberError Function(String, dynamic) _errorBuilder;

  NumberValidator._(this._parser, this._errorBuilder);

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    if (propertyValue != null && _parser(propertyValue) == null) {
      return [NumberError.integer(propertyName, propertyValue)];
    }
    return [];
  }
}

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
