import 'package:controller/controller.dart';
import 'package:test/test.dart';

part 'unique_test.g.dart';

void main() {
  group('Unique body field', () {
    test('should succeed when field is unique', () async {
      var result = await CommandWithUnique$Validator.instance.validateEntity(
        CommandWithUnique('unique'),
      );
      expect(result.length, 0);
    });

    test('should fail when field is not unique', () async {
      var result = await CommandWithUnique$Validator.instance.validateEntity(
        CommandWithUnique('not-unique'),
      );
      expect(result.length, 1);
    });
  });
}

@validatable
class CommandWithUnique {
  @Unique(exists)
  final String unique;

  CommandWithUnique(this.unique);
}

Future<bool> exists(String value) async => value == 'not-unique';
