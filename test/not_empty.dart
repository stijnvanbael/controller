import 'dart:convert';

import 'package:controller/controller.dart';
import 'package:controller/src/validation/not_empty.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

part 'not_empty.g.dart';

void main() {
  group('Non empty body property', () {
    test('should succeed when field is not empty', () async {
      var result = await CommandWithNotEmpty$Validator.instance.validateEntity(
        CommandWithNotEmpty(
          notEmptyField: 'something',
        ),
      );
      expect(result.length, 0);
    });

    test('should not fail when field is null', () async {
      var result = await CommandWithNotEmpty$Validator.instance.validateEntity(
        CommandWithNotEmpty(
          notEmptyField: null,
        ),
      );
      expect(result.length, 0);
    });

    test('should fail when field is empty', () async {
      var result = await CommandWithNotEmpty$Validator.instance.validateEntity(
        CommandWithNotEmpty(
          notEmptyField: '',
        ),
      );
      expect(result.length, 1);
    });
  });

  group('Non empty controller header', () {
    var requestDispatcher = createRequestDispatcher([
      NotEmptyController$DispatcherBuilder(NotEmptyController()),
    ]);

    test('should succeed when header is not empty', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/not-empty-header'),
        body: '''
          {
            "notEmptyField": "something"
          }
          ''',
        headers: {
          'header': 'something',
        },
      ));
      expect(response.statusCode, 200);
    });

    test('should succeed when header is null', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/not-empty-header'),
        body: '''
          {
            "notEmptyField": "something"
          }
          ''',
      ));
      expect(response.statusCode, 200);
    });


    test('should fail when header is empty', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/not-empty-header'),
        body: '''
          {
            "notEmptyField": "something"
          }
          ''',
        headers: {
          'header': '',
        },
      ));
      expect(response.statusCode, 400);
    });
  });
}

@controller
class NotEmptyController {
  @Post('/not-empty-header')
  Future<Response> notEmptyParam(
    @body CommandWithNotEmpty command,
    @notEmpty String? header,
  ) =>
      Future.value(Response.ok('OK'));
}

@validatable
class CommandWithNotEmpty {
  @notEmpty
  final String? notEmptyField;

  CommandWithNotEmpty({this.notEmptyField});

  CommandWithNotEmpty.fromJson(Map<String, dynamic> json)
      : this(notEmptyField: json['notEmptyField']);
}
