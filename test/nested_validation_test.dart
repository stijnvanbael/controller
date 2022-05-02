import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

part 'nested_validation_test.g.dart';

void main() {
  group('Nested validation', () {
    var requestDispatcher = createRequestDispatcher([
      NestedValidationController$DispatcherBuilder(NestedValidationController())
    ]);

    test('should succeed when body is valid', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/nested'),
        body: '''
          {
            "nestedSet": [
              { "value": "valid" }
            ],
            "nestedList": [
              { "value": "valid" }
            ]
          }
          ''',
      ));
      expect(response.statusCode, 200);
    });

    test('should fail when set contains invalid value', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/nested'),
        body: '''
          {
            "nestedSet": [
              { "value": "valid" },
              { "value": null }
            ],
            "nestedList": [
              { "value": "valid" }
            ]
          }
          ''',
      ));
      expect(response.statusCode, 400);
    });

    test('should fail when list contains invalid value', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/nested'),
        body: '''
          {
            "nestedSet": [
              { "value": "valid" }
            ],
            "nestedList": [
              { "value": "valid" },
              { "value": null }
            ]
          }
          ''',
      ));
      expect(response.statusCode, 400);
    });

    test('should fail when list is of invalid type', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/nested'),
        body: '''
          {
            "nestedSet": [
              { "value": "valid" }
            ],
            "nestedList":  "invalid"
          }
          ''',
      ));
      expect(response.statusCode, 400);
    });

    test('should fail when set contains invalid type', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/nested'),
        body: '''
          {
            "nestedSet": [
              "invalid"
            ],
            "nestedList":  [
              { "value": "valid" }
            ]
          }
          ''',
      ));
      expect(response.statusCode, 400);
    });
  });
}

@controller
class NestedValidationController {
  @Post('/nested')
  Future<Response> nestedValidation(@body NestedCommand command) =>
      Future.value(Response.ok('OK'));
}

@validatable
class NestedCommand {
  final Set<SubCommand> nestedSet;
  final List<SubCommand> nestedList;

  NestedCommand(this.nestedSet, this.nestedList);

  NestedCommand.fromJson(Map<String, dynamic> json)
      : this(
          (json['nestedSet'] as List<dynamic>)
              .map((value) => SubCommand.fromJson(value))
              .toSet(),
          (json['nestedList'] as List<dynamic>)
              .map((value) => SubCommand.fromJson(value))
              .toList(),
        );
}

@validatable
class SubCommand {
  final String value;

  SubCommand(this.value);

  SubCommand.fromJson(Map<String, dynamic> json) : this(json['value']);
}
