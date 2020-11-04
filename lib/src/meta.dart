library controller.meta;

const controller = Controller();
const bodyProperty = BodyProperty();
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

class Body {
  const Body();
}

class Validatable {
  const Validatable();
}

class Required {
  const Required();
}
