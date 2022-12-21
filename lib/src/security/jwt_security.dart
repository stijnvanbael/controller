import 'dart:async';

import 'package:controller/controller.dart';
import 'package:logging/logging.dart';
import 'package:openid_client/openid_client.dart';

class JwtSecurity implements Security {
  static final Logger _log = Logger('JwtSecurity');
  final Uri issuerUri;
  final String clientId;

  JwtSecurity({
    required this.issuerUri,
    required this.clientId,
  });

  @override
  Future<bool> verify(Map<String, String> headers, Secured secured) async {
    final token = _getToken(headers);
    if (token == null) {
      return false;
    }
    final issuer = await Issuer.discover(issuerUri);
    final client = Client(issuer, clientId);
    final credential = client.createCredential(idToken: token);
    final exceptions = await credential.validateToken().toList();
    if (exceptions.isNotEmpty) {
      _log.fine('Token validation failed: $exceptions');
      return false;
    }
    return secured.condition.evaluate(
      credential.idToken.claims.toJson(),
      headers,
    );
  }

  String? _getToken(Map<String, String> headers) {
    final authorization = headers['authorization'] ?? headers['Authorization'];
    if (authorization == null) {
      _log.fine('Header "authorization" not found');
      return null;
    }
    if (!authorization.startsWith('Bearer ')) {
      _log.fine('Header "authorization" did not contain bearer token');
      return null;
    }
    return authorization.substring('Bearer '.length);
  }
}
