import 'dart:convert';

import 'package:controller/src/security/security.dart';

class HttpBasicAuthSecurity implements Security {
  static final String authorization_header = 'authorization';
  static final String prefix = 'Basic ';
  static final Codec<String, String> decoder = utf8.fuse(base64);
  final IdentityProvider identityProvider;

  HttpBasicAuthSecurity(this.identityProvider);

  @override
  bool verify(Map<String, String> headers, List<String> requiredClaims) {
    var authorization = headers[authorization_header];
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
    return requiredClaims.every((claim) => claims.contains(claim));
  }
}

abstract class IdentityProvider {
  List<String> getClaims(String username, String password);
}

class SimpleIdentityProvider implements IdentityProvider {
  final Map<String, SimpleIdentity> _identities;

  SimpleIdentityProvider(this._identities);

  @override
  List<String> getClaims(String username, String password) {
    var identity = _identities[username];
    return identity?.password == password ? identity.claims.toList() : null;
  }
}

class SimpleIdentity {
  String password;
  List<String> claims;

  SimpleIdentity(this.password, [this.claims = const []]);
}
