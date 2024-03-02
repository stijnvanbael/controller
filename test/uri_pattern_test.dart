import 'package:controller/src/dispatcher/uri_pattern.dart';
import 'package:test/test.dart';

void main() {
  for (var testSet in [
    {
      'pattern': '/without-trailing-slash',
      'uri': '/with-trailing-slash/',
      'matches': false
    },
    {
      'pattern': '/without-trailing-slash',
      'uri': '/without-trailing-slash',
      'matches': true
    },
    {
      'pattern': '/without-trailing-slash',
      'uri': '/without-trailing-slash/',
      'matches': true
    },
    {
      'pattern': '/with-trailing-slash/',
      'uri': '/with-trailing-slash',
      'matches': true
    },
    {
      'pattern': '/with-trailing-slash/',
      'uri': '/with-trailing-slash/',
      'matches': true
    },
    {
      'pattern': 'without-leading-slash/',
      'uri': '/without-leading-slash/',
      'matches': true
    },
    {'pattern': 'path/with/:param', 'uri': '/path/with/value', 'matches': true},
    {
      'pattern': 'path/with/:param',
      'uri': '/path/with/some-value',
      'matches': true
    },
    {'pattern': '', 'uri': '/', 'matches': true},
    {'pattern': '', 'uri': '', 'matches': true},
    {'pattern': '/', 'uri': '', 'matches': true},
    {'pattern': '/', 'uri': '/', 'matches': true},
  ]) {
    var pattern = testSet['pattern'] as String;
    var uri = testSet['uri'] as String;
    var matches = testSet['matches'] as bool;
    test('Pattern "$pattern" should ${matches ? '' : 'not '}match URI "$uri"',
        () {
      var uriPattern = UriPattern(pattern);
      expect(uriPattern.matches(uri), matches);
    });
  }
}
