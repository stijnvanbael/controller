# Controller

Controller is a library that facilitates writing HTTP request handlers with Shelf.

## Features

* Request mapping
* Validation
* Security

## Getting started

Add the Controller libraries to pubspec.yaml:

```yaml
dependencies:
  controller: ^0.1.4
  json_annotation: ^4.5.0

dev_dependencies:
  build_runner: ^2.1.10
  controller_generator: ^0.1.4
  json_serializable: ^6.2.0
```

## Usage

### Controller

* Add the `@controller` metadata to the class where you want to handle requests.
* Annotate handler methods with HTTP verbs (`@Get`, `@Put`, `@Delete`, ...).
* Use `@body` to deserialize a JSON body to an object.
* Prefix path parameters with a colon.

```dart
import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';

part 'todo_controller.g.dart';

@controller
class TodoController {
  @Post('/todos')
  Future<Response> addTodo(@body Todo todo) {
    // implementation goes here
  }

  @Get('/todos/:id')
  Future<Response> getTodo(String id) {
    // implementation goes here
  }
}
```

### Request body

* Annotate classes mapped to the request body with `@validatable`.
* Annotate fields with validator metadata.
* Add a `fromJson()` factory method.

```dart
import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@validatable
@JsonSerializable(createToJson: false)
class Todo {
  @notEmpty
  final String id;
  @notEmpty
  final String description;

  Todo({
    required this.id,
    required this.description,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
```

### Validation

* Validation metadata can be added on request bodies and controller parameters
* Out-of-the-box available validators include:
    * `@Min(value)` and `@Max(value)`
    * `@Length(min, max)`
    * `@notEmpty`
    * `@Regex(pattern, description)`
    * `@Unique(existsPredicate)`

### Returning responses

* You can return Shelf Response objects.
* When returning an object with a `toJson` method, a `200 OK` response is returned with the JSON as body.

```dart
import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo_controller.g.dart';

@controller
class TodoController {
  @Post('/todos')
  // Returning Future<void> will return an empty `200 OK` response.
  Future<void> addTodo(@body Todo todo) {
    // implementation goes here
  }

  @Get('/todos/:id')
  // Returning Future<A> will call `A.toJson()` and return a `200 OK` response
  // with the JSON in the body.
  Future<Todo> getTodo(String id) {
    // implementation goes here
  }
}

@JsonSerializable()
class Todo {
  @notEmpty
  final String id;
  @notEmpty
  final String description;

  Todo({
    required this.id,
    required this.description,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);
}
```

### Securing requests

* Add a `@Secured` metadata to the endpoints you want to protect with security.
* `@Secured` takes a parameter with a condition the request has to comply with.
* You can either use off the shelf conditions or write your own.

```dart
import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';

part 'todo_controller.g.dart';

@controller
class TodoController {
  @Post('/todos')
  // Check whether the user has a claim "role" with value "todo-editor"
  @Secured(HasClaim('role', 'todo-editor'))
  Future<Response> addTodo(@body Todo todo) {
    // implementation goes here
  }

  @Get('/todos/:id')
  // Custom condition defined below
  @Secured(IsTodoOwner())
  Future<Response> getTodo(String id) {
    // implementation goes here
  }
}

class IsTodoOwner extends SecurityCondition {
  const IsTodoOwner();

  @override
  Future<bool> evaluate(Map<String, dynamic> claims, // the claims found in the token or user database
      Map<String, String> headers, // request headers and parameters
      ) async {
    final userId = claims['userId'];
    // When true, the user is allowed to access the endpoint
    return userId != null && headers['id'].startsWith(userId);
  }
}
```

### Setting up the server

Run `dart run build_runner build` to generate dispatcher builders and validators.

Create the request dispatcher with the generated dispatcher builders and wire it in Shelf:

```dart
import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'todo/todo_controller.dart';

void main() async {
  final todoController = TodoController();

  // Only required when you have secured controllers
  final security = JwtSecurity(
    issuerUri: Uri.parse('https://issuer.uri.goes.here'),
    clientId: 'your-applications-client-id',
  );

  final dispatcher = createRequestDispatcher([
    // Only controllers with @Secured methods will take the security parameter
    TodoController$DispatcherBuilder(todoController, security),
  ]);
  final handler = Pipeline().addHandler(dispatcher);
  final server = await serve(handler, '0.0.0.0', 8080);
}
```
