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

AsyncPatternMatcher<Request, FutureOr<Response>> newRequestMatcher() => asyncMatcher<Request, FutureOr<Response>>();

TransformingPredicate<Request, Future<Pair<Map<String, String>, String>>> matchRequest(String method,
    String pathExpression) {
  var pattern = UriPattern(pathExpression);
  return predicate(
        (Request request) => request.method == method && pattern.matches(request.requestedUri.path),
        (Request request) async => Pair(_extractHeaders(request, pattern), await request.readAsString()),
    '$method $pathExpression',
  );
}

Map<String, String> _extractHeaders(Request request, UriPattern pathPattern) {
  var headers = Map<String, String>.from(request.headers);
  var pathParams = pathPattern.parse(request.requestedUri.path);
  pathParams.forEach((k, v) => headers[k] = v);
  return headers;
}

extension RequestMatcher on AsyncPatternMatcher<Request, FutureOr<Response>> {
  AsyncPatternMatcher<Request, FutureOr<Response>> appendMatchers(DispatcherBuilder dispatcherBuilder) =>
      dispatcherBuilder.appendMatchers(this);

  AsyncPatternMatcher<Request, FutureOr<Response>> addCorsHeaders() =>
      when2(
        matchRequest('OPTIONS', '/**'),
            (Map<String, String> headers, body) => Response.ok(null, headers: corsHeaders),
      );
}
