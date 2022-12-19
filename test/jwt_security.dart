import 'dart:async';

import 'package:controller/controller.dart';
import 'package:controller/src/security/jwt_security.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:jwk/jwk.dart';
import 'package:logging/logging.dart';
import 'package:pem/pem.dart';
import 'package:test/test.dart';

void main() {
  group('JWT Security', () {
    final security = JwtSecurity(
      keyProvider: SimpleKeyProvider(
        [
          RSAPublicKey('''
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6S7asUuzq5Q/3U9rbs+P
        kDVIdjgmtgWreG5qWPsC9xXZKiMV1AiV9LXyqQsAYpCqEDM3XbfmZqGb48yLhb/X
        qZaKgSYaC/h2DjM7lgrIQAp9902Rr8fUmLN2ivr5tnLxUUOnMOc2SQtr9dgzTONY
        W5Zu3PwyvAWk5D6ueIUhLtYzpcB+etoNdL3Ir2746KIy/VUsDwAM7dhrqSK8U2xF
        CGlau4ikOTtvzDownAMHMrfE7q1B6WZQDAQlBmxRQsyKln5DIsKv6xauNsHRgBAK
        ctUxZG8M4QJIx3S6Aughd3RZC4Ca5Ae9fd8L8mlNYBCrQhOZ7dS0f4at4arlLcaj
        twIDAQAB
        -----END PUBLIC KEY-----
        ''')
        ],
      ),
      targetAudience: 'controller-test',
      expectedIssuer: 'test-issuer',
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

    test('Invalid token', () async {
      final headers = {'authorization': 'Bearer foobar'};

      final result = await security.verify(headers, secured);

      expect(result, false);
    });

    test('Invalid signature', () async {
      final headers = {'authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTY3MTQ3Njg3MywiZXhwIjoxNjcxNDgwNDczfQ.SHTENbk721p9NxP4KlIH5DZ9_QBCiseYtB_sfoB-r_wYGWBTR-Caowfv1S5uSqWsWlbG5lcZj1kci14CxTf_g9k_5kc9pm4DnjNAGU22Xd_4srMlQGefnKke2sTdIJalbr9OoZlrozpMxUJlWAjoCICGuNjJtQRJ0aITS41xCIUXPrt3Qji9VNvtB6UtRvDTXFQclMoEL4IkSbOl65mmKXPrlYiQhANJ0tOKDPOPv6ouTobeXmpBeZAc9p8GNbnnR7lwIZ2vos8C3qNXv9vDHh-uJ2G5z0teWmBCiIV-2-Opd78ZpYQB3aawuxD4o-ymlNrwj-XD-4whz9lJemJ1dQ'};

      final result = await security.verify(headers, secured);

      expect(result, false);
    });

    test('Invalid audience', () async {
      final headers = {'authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJ0ZXN0LWlzc3VlciIsImlhdCI6MTY3MTQ3NTUzNiwiZXhwIjoyNTM0MDEyNDUxMzYsImF1ZCI6ImZvb2JhciIsInN1YiI6ImpvaG4uZG9lQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiJ9.S5XDyiBlSz3OiU5CQxgvoItGtUS4AucEnzkCZtO4eo0YdFSd80qiBt3eqauJdxg4NlQUrPUOU8RMmR0SBwTT2-SzFAf43ZghdICBUGdNixbPDjhxg2O-b-Z4NPPq_x1r-Yf9bGbDI6L3xF7DbDwBwM8JFR60AR4XGiyRlgNQhRYIojnCh5sWZwLWKtJktvEooo-D1lTA125TCEH02YBJb9mK2dkYOiL03g3mzuOFQZD_kZsPDbqkmgilj9cOVtL7Qgud5bzHoXkcIqhLqeNeTZSg2V6l3iYseyLd54eQD-mnP3WsqM6KeW9L4w53PAxv_z0SelOTkWxD8gQruNUH_w'};

      final result = await security.verify(headers, secured);

      expect(result, false);
    });

    test('Expired', () async {
      final headers = {'authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJ0ZXN0LWlzc3VlciIsImlhdCI6MTU3Njc4MTEzNiwiZXhwIjoxNjA4NDAzNTM2LCJhdWQiOiJjb250cm9sbGVyLXRlc3QiLCJzdWIiOiJqb2huLmRvZUBnbWFpbC5jb20iLCJyb2xlIjoiYWRtaW4ifQ.WI14uXh3sBmuz6T0P5zgnTVfQL4Q714plxxTAHZ2YFcSVcOvmbgI4Z3Ooz5v5P5uUZR2AgeQ_3O_lq4dhpJE7laoDmlQfK_moSvtXAzSlUIJXaHfXdXFNB1tpPaTGAHn0l3Wd9M8d5DPCGnza2wPIyeoaZPI1JfueS7qsYZd_fKO2FwL57Usjklw-xpAsJGnB9OGK3t7oaDlG5dWH02Xi3AIWJM6fHtKNI4_TJXkYoAd4gCmxN8UZ-H_dKPkfKSZusBLDSx4iEKkSZ_XYBiRBQIERibJCkOx6MDrYWPZnEYXlUW9RClMHsoBGfo7y8918Z6A5zxW_dyVL80_p9_kuQ'};

      final result = await security.verify(headers, secured);

      expect(result, false);
    });

    test('Missing claims', () async {
      final headers = {'authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJ0ZXN0LWlzc3VlciIsImlhdCI6MTY3MTQ3NTUzNiwiZXhwIjoyNTM0MDEyNDUxMzYsImF1ZCI6ImNvbnRyb2xsZXItdGVzdCIsInN1YiI6ImpvaG4uZG9lQGdtYWlsLmNvbSIsInJvbGUiOiJyZWFkZXIifQ.VE1WwAVuCPogN94K7JSLUvOwuQyr79ea6J_b9uZ5TohudgdbhaG36U2GpQC3M1GGJdifgX0bMGmZR4Z5iMw_Lkq3O_l84ih_Giyl5CE9Egb2CvVdWVPrUbLiSZVJW1L77cPm14TKC8ET5GWHPcQNdNnMbhRERw3mN8mhWDRxPYLw_-pT50riM99nzpCf1rEM3AyCwwIVqLQX5VyHP4J71yg7oSFmXvLJYd9elgInR3wpG5LkeQlauBAY8ks1qIm9tgT8yRLRn6xyqY4egUL0FRQjmHVac0iFLLl_bCQd2qYZuoPhn2rKzgDr8EbWDnUcZz2R-RPN-tmEmv-pKbueQg'};

      final result = await security.verify(headers, secured);

      expect(result, false);
    });

    test('Valid token', () async {
      final headers = {
        'authorization':
            'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJ0ZXN0LWlzc3VlciIsImlhdCI6MTY3MTQ3NTUzNiwiZXhwIjoyNTM0MDEyNDUxMzYsImF1ZCI6ImNvbnRyb2xsZXItdGVzdCIsInN1YiI6ImpvaG4uZG9lQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiJ9.0UUqtWbfFd2PI93WtDDXMU7Xn_enD6ZHQnz904IFAHomtgWXLFdiN6v104Xha3PrIcKGKHVuaOlJye500euReg5DCUmpKcpGI5J8Ysqm1dSP5_qwpy-rrgFT946KrOPO_teC6SlqGDuh6SC7SOJK5ONA2zTng3l3ZWq7yk2wPOIYcjYbiTUQv9lC_a65l6Fki6JBcHXVlGaOpZPlR4ctzDMs7Wx8A5ad0MV23HUSy2iceJigkm3pfMYk31P0JaOSm_zOW1qapQaOalnp-wdKkod3C6QUEZtkKLkyYb1A9FuxbxtFSTntqffeTNtDkAoiXvWBcTJanPaOPyMpJKd9yA'
      };

      final result = await security.verify(headers, secured);

      expect(result, true);
    });
  });
}

class JwkKeyProvider implements KeyProvider {
  final Map<String, dynamic> json;

  JwkKeyProvider(this.json);

  @override
  Future<List<JWTKey>> getKeys() async {
    final jwk = Jwk.fromJson(json);
    final secretKey = jwk.toSecretKey();
    final pem =
        PemCodec(PemLabel.publicKey).encode(await secretKey.extractBytes());
    return [RSAPublicKey(pem)];
  }
}
