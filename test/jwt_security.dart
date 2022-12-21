import 'package:controller/controller.dart';
import 'package:controller/src/security/jwt_security.dart';
import 'package:logging/logging.dart';
import 'package:openid_client/openid_client.dart';
import 'package:test/test.dart';

void main() {
  group('JWT Security', () {
    final security = JwtSecurity(
      issuerUri: Issuer.google,
      clientId: 'controller-test',
    );
    final secured = Secured(HasClaim('role', 'admin'));
    Logger.root.level = Level.FINE;

    test('Authorization header not found', () async {
      final headers = {'auth': 'foobar'};

      final result = await security.verify(headers, secured);

      expect(result, false);
    });

    test('Authorization header missing bearer', () async {
      final headers = {'authorization': 'foo:bar'};

      final result = await security.verify(headers, secured);

      expect(result, false);
    });
  });
}
