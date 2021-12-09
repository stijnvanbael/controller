import 'dart:convert';

import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

part 'required.g.dart';

void main() {
  group('Required validation', () {
    test('should succeed when not null', () async {
      var result = await CommandWithRequired$Validator.instance.validateEntity(
        CommandWithRequired(
          requiredField: 'something',
          nestedField: NestedWithRequired(requiredField: 'something'),
        ),
      );
      expect(result.length, 0);
    });

    test('should fail when empty String', () async {
      var result = await CommandWithRequired$Validator.instance.validateEntity(
        CommandWithRequired(
          requiredField: '',
          nestedField: NestedWithRequired(requiredField: ''),
        ),
      );
      expect(result.length, 2);
    });

    test('should fail when null', () async {
      var result =
          await CommandWithRequired$Validator.instance.validateDocument(
        {
          'requiredField': null,
          'nestedField': {
            'requiredField': null,
          },
        },
      );
      expect(result.length, 2);
    });
  });
}

@controller
class RequiredController {
  @Post('/required')
  Future<Response> required(@body CommandWithRequired command) =>
      Future.value(Response.ok('OK'));
}

@validatable
class CommandWithRequired {
  @required
  final String requiredField;
  final NestedWithRequired? nestedField;

  CommandWithRequired({
    required this.requiredField,
    this.nestedField,
  });

  CommandWithRequired.fromJson(Map<String, dynamic> json)
      : this(
          requiredField: json['requiredField'],
          nestedField: json['nestedField'] != null
              ? NestedWithRequired.fromJson(json['nestedField'])
              : null,
        );
}

@validatable
class NestedWithRequired {
  @required
  final String requiredField;

  NestedWithRequired({
    required this.requiredField,
  });

  NestedWithRequired.fromJson(Map<String, dynamic> json)
      : this(requiredField: json['requiredField']);
}
