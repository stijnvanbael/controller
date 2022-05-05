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

* Add the `@controller` metadata to the class where you want to handle requests.
* Annotate handler methods with HTTP verbs (`@Get`, `@Put`, `@Delete`, ...).
* Use `@body` to deserialize a JSON body to an object.
* Start path parameters with a semicolon.

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

* Annotate classes mapped to the request body with `@validatable`.
* Annotate fields with validator metadata.
* Add a `fromJson()` factory method.

```dart
import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@validatable
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
}
```

Run `dart run build_runner build` to generate dispatcher builders and validators.

Create the request dispatcher with the generated dispatcher builders and wire it in Shelf:

```dart
import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'todo/todo_controller.dart';

void main() async  {
  var todoController = TodoController();
  var dispatcher = createRequestDispatcher([
    TodoController$DispatcherBuilder(todoController),
  ]);
  var handler = Pipeline().addHandler(dispatcher);
  var server = await serve(handler, '0.0.0.0', 8080);
}
```
