import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// A `http.Client` whose response is entirely determined by [handler] —
/// no real network call, so provider tests are deterministic and don't
/// depend on a live service or API key being available.
class FakeHttpClient extends http.BaseClient {
  FakeHttpClient(this.handler);

  final FutureOr<http.Response> Function(Uri uri) handler;
  final List<Uri> requestedUris = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestedUris.add(request.url);
    final response = await handler(request.url);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
    );
  }
}

http.Response jsonResponse(Object body, {int statusCode = 200}) =>
    http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
