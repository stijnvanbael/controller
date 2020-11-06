class UriPattern {
  final String pattern;
  final List<String> _parameters = [];
  RegExp _regExp;

  UriPattern(this.pattern) {
    if (pattern.contains('?')) {
      throw 'Pattern "$pattern" shoud not contain query parameters';
    }
    _regExp = _createRegExp(pattern);
  }

  bool matches(String string) => _regExp.hasMatch(string);

  Map<String, String> parse(String string) {
    var match = _regExp.firstMatch(string);
    if (match == null) {
      return null;
    }
    var result = <String, String>{};
    _parameters.forEach((param) {
      result[param] = match[_parameters.indexOf(param) + 1];
    });
    return result;
  }

  RegExp _createRegExp(String pattern) => RegExp(r'^' +
      _normalize(pattern).replaceAllMapped(RegExp(r'(\*\*)|(:[\w]+)|([^:*]+)', caseSensitive: false), (Match m) {
        if (m[2] != null) {
          _parameters.add(m[2].substring(1));
          return r'(\w+)';
        } else if (m[3] != null) {
          return _quote(m[3]);
        } else {
          return '.*';
        }
      }) +
      r'?$');

  String _quote(String string) =>
      string.replaceAllMapped(RegExp(r'([.?\\\[\]{\}\-*$^+<>|])|(.)'), (m) => m[1] != null ? r'\' + m[1] : m[2]);

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
