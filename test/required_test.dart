import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

part 'required_test.g.dart';

void main() {
  group('Required body property', () {
    test('should succeed when field is not null', () async {
      var result = await CommandWithRequired$Validator.instance.validateEntity(
        CommandWithRequired(
          requiredField: 'something',
          nestedField: NestedWithRequired(requiredField: 'something'),
        ),
      );
      expect(result.length, 0);
    });

    test('should fail when field is null', () async {
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

  group('Required controller parameter', () {
    var requestDispatcher = createRequestDispatcher([
      RequiredController$DispatcherBuilder(RequiredController()),
    ]);

    test('should succeed when body is not null', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/required-body'),
        body: '''
          {
            "requiredField": "something",
            "nestedField": {
              "requiredField": "something"
            }
          }
          ''',
      ));
      expect(response.statusCode, 200);
    });

    test('should fail when body is null', () async {
      var response = await requestDispatcher(Request(
        'POST',
        Uri.parse('https://test.dev/required-body'),
        body: null,
      ));
      expect(response.statusCode, 400);
    });
  });
}

@controller
class RequiredController {
  @Post('/required-body')
  Future<Response> requiredBody(@body CommandWithRequired command) =>
      Future.value(Response.ok('OK'));
}

@validatable
@JsonSerializable(createToJson: false)
class CommandWithRequired {
  final String requiredField;
  final String? optionalField;
  final NestedWithRequired? nestedField;

  CommandWithRequired({
    required this.requiredField,
    this.optionalField,
    this.nestedField,
  });

  String get syntheticField => requiredField;

  factory CommandWithRequired.fromJson(Map<String, dynamic> json) =>
      _$CommandWithRequiredFromJson(json);
}

@validatable
@JsonSerializable(createToJson: false)
class NestedWithRequired {
  final String requiredField;
  final String? optionalField;

  NestedWithRequired({
    required this.requiredField,
    this.optionalField,
  });

  factory NestedWithRequired.fromJson(Map<String, dynamic> json) =>
      _$NestedWithRequiredFromJson(json);
}
