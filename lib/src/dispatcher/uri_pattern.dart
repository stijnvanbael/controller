class UriPattern {
  final String pattern;
  final List<String> _parameters = [];
  RegExp _regExp = RegExp('.*');

  UriPattern(this.pattern) {
    if (pattern.contains('?')) {
      throw 'Pattern "$pattern" shoud not contain query parameters';
    }
    _regExp = _createRegExp(pattern);
  }

  bool matches(String string) => _regExp.hasMatch(string);

  Map<String, String>? parse(String string) {
    var match = _regExp.firstMatch(string);
    if (match == null) {
      return null;
    }
    var result = <String, String>{};
    for (var param in _parameters) {
      result[param] = match[_parameters.indexOf(param) + 1]!;
    }
    return result;
  }

  RegExp _createRegExp(String pattern) => RegExp(r'^' +
      _normalize(pattern).replaceAllMapped(
          RegExp(r'(\*\*)|(:[\w]+)|([^:*]+)', caseSensitive: false), (Match m) {
        var parameterName = m[2];
        var intermediate = m[3];
        if (parameterName != null) {
          _parameters.add(parameterName.substring(1));
          return r'([^/?]+)';
        } else if (intermediate != null) {
          return _quote(intermediate);
        } else {
          return '.*';
        }
      }) +
      r'?$');

  String _quote(String string) => string.replaceAllMapped(
      RegExp(r'([.?\\\[\]{\}\-*$^+<>|])|(.)'),
      (m) => m[1] != null ? r'\' + m[1]! : m[2]!);

  String _normalize(String pattern) {
    if (!pattern.startsWith('/')) {
      pattern = '/$pattern';
    }
    if (!pattern.endsWith('/')) {
      pattern = '$pattern/';
    }
    return pattern;
  }
}
