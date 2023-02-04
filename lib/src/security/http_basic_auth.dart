import 'dart:convert';

import 'package:controller/src/security/security.dart';

import '../meta.dart';

/// HTTP basic authentication security that will read username and password
/// from the Authorization header.
///
/// The identity provider will be used to validate the username/password
/// combination and fetch the claims of the client.
///
/// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication
class HttpBasicAuthSecurity implements Security {
  static final String authorizationHeader = 'authorization';
  static final String prefix = 'Basic ';
  static final Codec<String, String> decoder = utf8.fuse(base64);
  final IdentityProvider identityProvider;

  HttpBasicAuthSecurity(this.identityProvider);

  @override
  Future<bool> verify(Map<String, String> headers, Secured secured) async {
    var authorization = headers[authorizationHeader];
    if (authorization == null) {
      return false;
    }
    if (!authorization.startsWith(prefix)) {
      return false;
    }
    var decoded = decoder.decode(authorization.substring(prefix.length));
    if (!decoded.contains(':')) {
      return false;
    }
    var splitted = decoded.split(':');
    var claims = identityProvider.getClaims(splitted[0], splitted[1]);
    if (claims == null) {
      return false;
    }
    return secured.condition.evaluate(claims, headers);
  }
}

/// Provides identity information for clients
abstract class IdentityProvider {
  /// Validates the username/password combination is valid
  /// and returns the claims of the client.
  /// Returns null when the username does not exist or the password is
  /// incorrect.
  Map<String, String>? getClaims(String username, String password);
}

/// Simple identity provider that stores identities in a map in memory.
class SimpleIdentityProvider implements IdentityProvider {
  final Map<String, SimpleIdentity> _identities;

  SimpleIdentityProvider(this._identities);

  @override
  Map<String, String>? getClaims(String username, String password) {
    var identity = _identities[username];
    return identity?.password == password ? identity?.claims : null;
  }
}

class SimpleIdentity {
  String password;
  Map<String, String> claims;

  SimpleIdentity(this.password, [this.claims = const {}]);
}
