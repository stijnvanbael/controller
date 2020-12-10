import '../../controller.dart';
import 'common.dart';

const required = Required();

bool always(dynamic entity) => true;

class Required extends PropertyValidator {
  final Predicate when;

  const Required([this.when = always]);

  @override
  List<ValidationError> validateProperty(
      dynamic entity, String propertyName, dynamic propertyValue) {
    if (when(entity) &&
        (propertyValue == null ||
            (propertyValue is String && propertyValue.isEmpty))) {
      return [RequiredError(propertyName)];
    }
    return [];
  }
}

class RequiredError extends ValidationError {
  final String propertyName;

  RequiredError(this.propertyName) : super('required');

  @override
  String toString() => 'A value for $propertyName is required.';

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'propertyName': propertyName,
        'message': toString(),
      };
}
