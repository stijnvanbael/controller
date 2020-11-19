library controller.meta;

const controller = Controller();
const bodyProperty = BodyProperty();
const secured = Secured();
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

class Secured {
  final List<String> claims;

  const Secured([this.claims = const []]);
}

class Body {
  const Body();
}
