library controller.meta;

import 'dart:async';

const controller = Controller();
const bodyProperty = BodyProperty();
const body = Body();

class Controller {
  const Controller();
}

class Get extends HttpRequest {
  const Get(String path) : super('GET', path);
}

class Post extends HttpRequest {
  const Post(String path) : super('POST', path);
}

class Put extends HttpRequest {
  const Put(String path) : super('PUT', path);
}

class Delete extends HttpRequest {
  const Delete(String path) : super('DELETE', path);
}

class Head extends HttpRequest {
  const Head(String path) : super('HEAD', path);
}

class Patch extends HttpRequest {
  const Patch(String path) : super('PATCH', path);
}

class HttpRequest {
  final String method;
  final String path;

  const HttpRequest(this.method, this.path);
}

class BodyProperty {
  const BodyProperty();
}

class Body {
  const Body();
}

class Secured {
  final SecurityCondition condition;
  final int statusCode;

  const Secured(
    this.condition, {
    this.statusCode = 401,
  });
}

abstract class SecurityCondition {
  const SecurityCondition();

  FutureOr<bool> evaluate(
      Map<String, dynamic> claims, Map<String, String> headers);
}

class HasClaim extends SecurityCondition {
  final String name;
  final String value;

  const HasClaim(this.name, this.value);

  @override
  bool evaluate(Map<String, dynamic> claims, Map<String, String> headers) =>
      claims[name] == value;
}
