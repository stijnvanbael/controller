import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

part 'valid_json_test.g.dart';

void main() {
  group('JSON controller body', () {
    var requestDispatcher = createRequestDispatcher([
      JsonController$DispatcherBuilder(JsonController()),
    ]);

    test('should succeed when body is valid JSON', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/json'),
        body: '''
          {
            "field": "something"
          }
          ''',
      ));
      expect(response.statusCode, 200);
    });

    test('should succeed when body is null', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/json'),
        body: null,
      ));
      expect(response.statusCode, 200);
    });

    test('should fail when body is invalid JSON', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/json'),
        body: '''
          {
            "field": OOPS
          }
          ''',
      ));
      expect(response.statusCode, 400);
    });
  });
}

@controller
class JsonController {
  @Post('/json')
  Future<Response> requiredBody(@body JsonCommand? command) =>
      Future.value(Response.ok('OK'));
}

@validatable
@JsonSerializable(createToJson: false)
class JsonCommand {
  final String? field;

  JsonCommand({this.field});

  factory JsonCommand.fromJson(Map<String, dynamic> json) =>
      _$JsonCommandFromJson(json);
}
