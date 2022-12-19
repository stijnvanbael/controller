import 'package:controller/src/meta.dart';

abstract class Security {
  Future<bool> verify(Map<String, String> headers, Secured secured);
}
