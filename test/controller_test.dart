import 'dart:convert';

import 'package:controller/controller.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

part 'controller_test.g.dart';

void main() {
  group('Controller', () {
    var controller = TestController();
    var dispatcher =
        createRequestDispatcher([TestController$DispatcherBuilder(controller)]);

    test('Simple request', () async {
      var request = Request('GET', Uri.parse('http://test/simple'));
      var response = await dispatcher(request);
      expect(response.statusCode, 200);
    });

    test('Path variable mapping', () async {
      var request = Request('GET', Uri.parse('http://test/path/value1/2'));
      var response = await dispatcher(request);
      expect(response.statusCode, 200);
      expect(await bodyOf(response), 'variable1: value1, variable2: 2');
    });

    test('Path variable mapping', () async {
      var request =
          Request('GET', Uri.parse('http://test/path/value1/invalid'));
      var response = await dispatcher(request);
      expect(response.statusCode, 400);
    });
  });
}

Future<String> bodyOf(Response response) {
  return utf8.decodeStream(response.read());
}

@controller
class TestController {
  @Get('/simple')
  Future<Response> simple() async {
    return Response.ok('');
  }

  @Get('/path/:variable1/:variable2')
  Future<Response> withPathVariables(
    String variable1,
    int variable2,
  ) async {
    return Response.ok('variable1: $variable1, variable2: $variable2');
  }
}
