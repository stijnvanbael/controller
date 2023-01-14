import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';

import 'pattern_matcher.dart';
import 'uri_pattern.dart';

final corsHeaders = {
  'access-control-allow-methods': 'GET, PUT, POST, DELETE, HEAD, PATCH',
  'access-control-allow-headers': '*',
};

abstract class DispatcherBuilder {
  AsyncPatternMatcher<Request, Response> appendMatchers(
      AsyncPatternMatcher<Request, Response> requestMatcher);

  List<Map<String, dynamic>> collectErrors(
          List<List<ValidationError>> errors) =>
      errors.expand((errors) => errors).map((error) => error.toJson()).toList();

  Response badRequest(List<Map<String, dynamic>> errors) => Response(
      HttpStatus.badRequest,
      body: jsonEncode({'errors': errors}),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.toString()});

  Response toResponse(dynamic value) {
    if (value is Response) {
      return value;
    } else if (value is String) {
      return Response.ok(value);
    } else if (value == null) {
      return Response.ok('');
    } else if (value.toJson != null) {
      return Response.ok(
        jsonEncode(value.toJson()),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.toString()},
      );
    } else {
      throw StateError('Cannot convert $value to a Response, '
          'please return a Response instead.');
    }
  }

  dynamic decodeJson(String? json) {
    try {
      return json != null && json.isNotEmpty ? jsonDecode(json) : null;
    } on FormatException {
      return null;
    }
  }
}

typedef RequestDispatcher = FutureOr<Response> Function(Request request);

Response defaultHandler(Request request) => Response.notFound('');

RequestDispatcher createRequestDispatcher(
  List<DispatcherBuilder> dispatcherBuilders, {
  bool corsEnabled = false,
  String allowedOrigins = '',
  Handler defaultHandler = defaultHandler,
}) {
  var requestMatcher = asyncMatcher<Request, Response>();
  if (corsEnabled) {
    if (allowedOrigins.isEmpty) {
      throw StateError(
          'CORS is enabled, but no allowed origins are specified.');
    }
    requestMatcher = requestMatcher.addCorsHandler();
  }
  dispatcherBuilders.forEach(
      (element) => requestMatcher = requestMatcher.appendMatchers(element));
  return (request) async {
    var response = await requestMatcher.otherwise(defaultHandler)(request);
    if (corsEnabled) {
      return response.change(headers: {
        ...response.headers,
        ...corsHeaders,
        'access-control-allow-origin': allowedOrigins
      });
    }
    return response;
  };
}

TransformingPredicate<Request, Future<Pair<Map<String, String>, String>>>
    matchRequest(String method, String pathExpression) {
  var pattern = UriPattern(pathExpression);
  return predicate(
    (Request request) =>
        request.method == method && pattern.matches(request.requestedUri.path),
    (Request request) async =>
        Pair(_extractHeaders(request, pattern), await request.readAsString()),
    '$method $pathExpression',
  );
}

Map<String, String> _extractHeaders(Request request, UriPattern pathPattern) {
  var headers = Map<String, String>.from(request.headers);
  pathPattern
      .parse(request.requestedUri.path)
      ?.forEach((k, v) => headers[k] = v);
  _parseQueryParams(request.requestedUri.query)
      .forEach((k, v) => headers[k] = v);
  return headers;
}

final RegExp queryRegexp = RegExp(r'(\w+)=([^&]+)');

Map<String, String> _parseQueryParams(String query) {
  var params = <String, String>{};
  queryRegexp
      .allMatches(query)
      .forEach((match) => params[match.group(1)!] = match.group(2)!);
  return params;
}

extension RequestMatcher on AsyncPatternMatcher<Request, Response> {
  AsyncPatternMatcher<Request, Response> appendMatchers(
          DispatcherBuilder dispatcherBuilder) =>
      dispatcherBuilder.appendMatchers(this);

  AsyncPatternMatcher<Request, Response> addCorsHandler() => when2(
        matchRequest('OPTIONS', '/**'),
        (Map<String, String> headers, body) => Response.ok(''),
      );
}
