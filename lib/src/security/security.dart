import 'package:controller/src/meta.dart';

/// Security handler that verifies security for requests.
abstract class Security {
  /// Verify the client is allowed to access this resource.
  /// Headers contains all HTTP headers, path and query parameters.
  /// Secured contains the security metadata on the annotated method.
  /// Implementations should extract the claims from headers and
  /// verify the condition in secured.
  Future<bool> verify(Map<String, String> headers, Secured secured);
}
