T convert<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  if (T == String) {
    return value != null ? value.toString() as T : null;
  } else if (T == int) {
    return value != null ? int.tryParse(value.toString()) as T : null;
  } else if (T == double) {
    return value != null ? double.tryParse(value.toString()) as T : null;
  } else if (T == num) {
    return value != null ? num.tryParse(value.toString()) as T : null;
  } else if (T == bool) {
    return value != null ? (value.toString() == 'true') as T : null;
  } else if (T == DateTime) {
    return value != null ? DateTime.tryParse(value.toString()) as T : null;
  } else {
    throw 'Cannot convert $value to $T';
  }
}
