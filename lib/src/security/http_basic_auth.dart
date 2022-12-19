import 'dart:convert';

import 'package:controller/src/security/security.dart';

import '../meta.dart';

class HttpBasicAuthSecurity implements Security {
  static final String authorization_header = 'authorization';
  static final String prefix = 'Basic ';
  static final Codec<String, String> decoder = utf8.fuse(base64);
  final IdentityProvider identityProvider;

  HttpBasicAuthSecurity(this.identityProvider);

  @override
  Future<bool> verify(Map<String, String> headers, Secured secured) async {
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
    return secured.condition.evaluate(claims, headers);
  }
}

abstract class IdentityProvider {
  Map<String, String>? getClaims(String username, String password);
}

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
