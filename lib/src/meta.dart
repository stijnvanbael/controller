library controller.meta;

const controller = Controller();
const bodyProperty = BodyProperty();

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
