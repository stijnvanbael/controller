import 'package:uuid/uuid.dart';

/// attempts to convert any value to the type T
T? convert<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return switch (T) {
    String => value != null ? value.toString() as T : null,
    int => value != null ? int.tryParse(value.toString()) as T : null,
    double => value != null ? double.tryParse(value.toString()) as T : null,
    num => value != null ? num.tryParse(value.toString()) as T : null,
    bool => value != null ? (value.toString() == 'true') as T : null,
    DateTime => value != null ? DateTime.tryParse(value.toString()) as T : null,
    UuidValue =>
      value != null ? UuidValue.fromString(value.toString()) as T : null,
    _ => throw 'Cannot convert $value to $T',
  };
}
