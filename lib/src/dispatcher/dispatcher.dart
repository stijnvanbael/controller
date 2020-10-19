import 'dart:async';

import 'package:shelf/shelf.dart';

import 'pattern_matcher.dart';
import 'uri_pattern.dart';

const corsHeaders = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, PUT, POST, DELETE, HEAD, PATCH',
  'access-control-allow-headers': '*',
};

abstract class DispatcherBuilder {
  AsyncPatternMatcher<Request, FutureOr<Response>> appendMatchers(
      AsyncPatternMatcher<Request, FutureOr<Response>> requestMatcher);
}

typedef RequestDispatcher = FutureOr<Response> Function(Request request);

RequestDispatcher createRequestDispatcher(
  List<DispatcherBuilder> dispatcherBuilders, {
  bool corsEnabled = false,
}) {
  var requestMatcher = asyncMatcher<Request, FutureOr<Response>>();
  if (corsEnabled) {
    requestMatcher = requestMatcher.addCorsHeaders();
  }
  dispatcherBuilders.forEach((element) => requestMatcher = requestMatcher.appendMatchers(element));
  return (request) async =>
      await requestMatcher.otherwise((Request request) => Future.value(Response.notFound('')))(request);
}

TransformingPredicate<Request, Future<Pair<Map<String, String>, String>>> matchRequest(
    String method, String pathExpression) {
  var pattern = UriPattern(pathExpression);
  return predicate(
    (Request request) => request.method == method && pattern.matches(request.requestedUri.path),
    (Request request) async => Pair(_extractHeaders(request, pattern), await request.readAsString()),
    '$method $pathExpression',
  );
}

Map<String, String> _extractHeaders(Request request, UriPattern pathPattern) {
  var headers = Map<String, String>.from(request.headers);
  pathPattern.parse(request.requestedUri.path).forEach((k, v) => headers[k] = v);
  _parseQueryParams(request.requestedUri.query).forEach((k, v) => headers[k] = v);
  return headers;
}

final RegExp queryRegexp = RegExp(r'(\w+)=([^&]+)');

Map<String, String> _parseQueryParams(String query) {
  var params = <String, String>{};
  queryRegexp.allMatches(query).forEach((match) => params[match.group(1)] = match.group(2));
  return params;
}

extension RequestMatcher on AsyncPatternMatcher<Request, FutureOr<Response>> {
  AsyncPatternMatcher<Request, FutureOr<Response>> appendMatchers(DispatcherBuilder dispatcherBuilder) =>
      dispatcherBuilder.appendMatchers(this);

  AsyncPatternMatcher<Request, FutureOr<Response>> addCorsHeaders() => when2(
        matchRequest('OPTIONS', '/**'),
        (Map<String, String> headers, body) => Response.ok(null, headers: corsHeaders),
      );
}
