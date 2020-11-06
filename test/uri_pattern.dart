import 'package:controller/src/dispatcher/uri_pattern.dart';
import 'package:test/test.dart';

void main() {
  [
    {'pattern': '/without-trailing-slash', 'uri': '/with-trailing-slash/', 'matches': false},
    {'pattern': '/without-trailing-slash', 'uri': '/without-trailing-slash', 'matches': true},
    {'pattern': '/without-trailing-slash', 'uri': '/without-trailing-slash/', 'matches': true},
    {'pattern': '/with-trailing-slash/', 'uri': '/with-trailing-slash', 'matches': true},
    {'pattern': '/with-trailing-slash/', 'uri': '/with-trailing-slash/', 'matches': true},
    {'pattern': 'without-leading-slash/', 'uri': '/without-leading-slash/', 'matches': true},
    {'pattern': '', 'uri': '/', 'matches': true},
    {'pattern': '', 'uri': '', 'matches': true},
    {'pattern': '/', 'uri': '', 'matches': true},
    {'pattern': '/', 'uri': '/', 'matches': true},
  ].forEach((testSet) {
    var pattern = testSet['pattern'];
    var uri = testSet['uri'];
    var matches = testSet['matches'];
    test('Pattern "$pattern" should ${matches ? '' : 'not '}match URI "$uri"', () {
      var uriPattern = UriPattern(pattern);
      expect(uriPattern.matches(uri), matches);
    });
  });
}
