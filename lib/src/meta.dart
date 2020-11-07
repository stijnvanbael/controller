library controller.meta;

const controller = Controller();
const bodyProperty = BodyProperty();
const secured = Secured();
const body = Body();
const validatable = Validatable();
const required = Required();

class Controller {
  const Controller();
}

class Get extends HttpRequest {
  const Get(String path) : super('GET', path);
}

class Post extends HttpRequest {
  const Post(String path) : super('POST', path);
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

class Validatable {
  const Validatable();
}

class Required {
  const Required();
}
