library controller.meta;

import 'dart:async';

const controller = Controller();
const body = Body();

/// Annotate a class to make it capable of handling HTTP requests.
/// Combine with HttpRequest annotated methods to write request handlers.
class Controller {
  const Controller();
}

/// Annotate a method to handle HTTP GET requests at the specified path
class Get extends HttpRequest {
  const Get(String path) : super('GET', path);
}

/// Annotate a method to handle HTTP POST requests at the specified path
class Post extends HttpRequest {
  const Post(String path) : super('POST', path);
}

/// Annotate a method to handle HTTP PUT requests at the specified path
class Put extends HttpRequest {
  const Put(String path) : super('PUT', path);
}

/// Annotate a method to handle HTTP DELETE requests at the specified path
class Delete extends HttpRequest {
  const Delete(String path) : super('DELETE', path);
}

/// Annotate a method to handle HTTP HEAD requests at the specified path
class Head extends HttpRequest {
  const Head(String path) : super('HEAD', path);
}

/// Annotate a method to handle HTTP PATH requests at the specified path
class Patch extends HttpRequest {
  const Patch(String path) : super('PATCH', path);
}

/// Annotate a method to handle HTTP requests with the specified method
/// at the specified path
class HttpRequest {
  final String method;
  final String path;

  const HttpRequest(this.method, this.path);
}

/// Annotate a method parameter to deserialize the HTTP request body.
/// Add a toJson factory method to the class to define how it should be
/// deserialized.
class Body {
  const Body();
}

/// Annotate a method to protect it with a security check.
/// When the condition returns false, the specified statusCode will
/// be returned instead.
class Secured {
  final SecurityCondition condition;
  final int statusCode;

  const Secured(
    this.condition, {
    this.statusCode = 401,
  });
}

/// A security condition for use with @Secured.
abstract class SecurityCondition {
  const SecurityCondition();

  /// Returns false when the client is not allowed to access the resource.
  /// Claims contains all security claims found for the principal
  /// (eg. in a JWT token).
  /// Headers returns all path and query parameters, and HTTP headers.
  FutureOr<bool> evaluate(
    Map<String, dynamic> claims,
    Map<String, String> headers,
  );
}

/// Check whether the client has a claim with the specified name and value.
class HasClaim extends SecurityCondition {
  final String name;
  final String value;

  const HasClaim(this.name, this.value);

  @override
  bool evaluate(Map<String, dynamic> claims, Map<String, String> headers) =>
      claims[name] == value;
}
