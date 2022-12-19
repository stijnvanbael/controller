import 'dart:async';
import 'dart:convert';

import 'package:controller/controller.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

final _dio = Dio();

class JwtSecurity implements Security {
  static final Logger _log = Logger('JwtSecurity');
  final KeyProvider keyProvider;
  final String targetAudience;
  final String expectedIssuer;

  JwtSecurity({
    required this.keyProvider,
    required this.targetAudience,
    required this.expectedIssuer,
  });

  @override
  Future<bool> verify(Map<String, String> headers, Secured secured) async {
    final token = _getToken(headers);
    if (token == null) {
      return false;
    }
    if (!(await _hasValidSignature(token))) {
      return false;
    }
    final jwt = _decodeToken(token);
    if (jwt == null) {
      return false;
    }
    if (!_matchesTargetAudience(jwt)) {
      return false;
    }
    final claims = _extractClaims(jwt);
    return secured.condition.evaluate(claims, headers);
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

  JWT? _decodeToken(String token) {
    try {
      return JWT.decode(token);
    } catch (e) {
      _log.fine('Failed to decode JWT token, reason: $e');
      return null;
    }
  }

  bool _matchesTargetAudience(JWT jwt) {
    if (jwt.payload['aud'] != targetAudience) {
      _log.fine(
          'Token audience does not match target audience "$targetAudience"');
      return false;
    }
    return true;
  }

  Future<bool> _hasValidSignature(String token) async {
    final keys = await keyProvider.getKeys();
    for (final key in keys) {
      try {
        JWT.verify(token, key);
        return true;
      } catch (e) {
        print(e);
        _log.fine('Failed to validate JWT signature, reason: $e');
      }
    }
    return false;
  }

  Map<String, dynamic> _extractClaims(JWT jwt) {
    return jwt.payload;
  }
}

abstract class KeyProvider {
  FutureOr<List<JWTKey>> getKeys();
}

class SimpleKeyProvider implements KeyProvider {
  final List<JWTKey> keys;

  SimpleKeyProvider(this.keys);

  @override
  List<JWTKey> getKeys() => keys;
}

class RemoteKeyProvider implements KeyProvider {
  final String certificateLocation;

  RemoteKeyProvider(this.certificateLocation);

  @override
  Future<List<JWTKey>> getKeys() async {
    final response = await _dio.get(certificateLocation);
    if (response.statusCode != null && response.statusCode! < 400) {
      final json = jsonDecode(response.data);
      return (json['keys'] as List<Map<String, String>>)
          .map((key) => RSAPublicKey(key['n']!))
          .toList();
    } else {
      throw StateError('Failed to fetch validation certificate: '
          '${response.statusCode} ${response.statusMessage}');
    }
  }
}
