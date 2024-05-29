import 'dart:async';
import 'dart:convert';

import 'raw_client.dart';

const _lineSeparator = '\r\n';
final _contentLengthRe = RegExp(r'^Content-Length: (\d+)$');

/// Medium-level client for LSP.
/// Sends and receives maps, awaits responses, notifies on notifications.
class LspMapClient extends LspRawListener {
  final _listeners = <LspMapListener>[];
  final LspRawClient _rawClient;
  final _completers = <int, Completer<Map<String, dynamic>?>>{};
  int _nextMessageId = 1;
  int? _contentLength;
  _State _state = _State.headers;
  String _unparsed = '';

  // ignore: public_member_api_docs
  LspMapClient({
    LspRawClient? rawClient,
  }) : _rawClient = rawClient ?? LspRawClient() {
    _rawClient.addListener(this);
  }

  /// Launches the server and connects to it.
  Future<void> start() async {
    await _rawClient.start();
  }

  /// Sends a message that calls the [method] with [params].
  Future send(String method, Map<String, dynamic> params) async {
    final messageId = _nextMessageId++;
    final request = {
      'jsonrpc': '2.0',
      'id': messageId,
      'method': method,
      'params': params,
    };
    final str = jsonEncode(request);
    final msg = 'Content-Length: ${str.length}\r\n\r\n$str\r\n';

    final completer = Completer<Map<String, dynamic>?>();
    _completers[messageId] = completer;

    _rawClient.writeString(msg);

    return completer.future;
  }

  /// Adds the [listener].
  void addListener(LspMapListener listener) {
    _listeners.add(listener);
  }

  @override
  void onData(List<int> data) {
    final str = String.fromCharCodes(data);
    _unparsed += str;
    _tryParse();
  }

  void _tryParse() {
    switch (_state) {
      case _State.headers:
        _tryParseHeaders();
      case _State.content:
        _tryParseContent();
    }
  }

  void _tryParseHeaders() {
    while (_tryParseHeader()) {
      if (_state == _State.content) {
        _tryParseContent();
        break;
      }
    }
  }

  bool _tryParseHeader() {
    final n = _unparsed.indexOf(_lineSeparator);
    if (n == -1) {
      return false;
    }

    final header = _unparsed.substring(0, n);
    _parseHeader(header);
    _unparsed = _unparsed.substring(n + _lineSeparator.length);
    return true;
  }

  void _parseHeader(String header) {
    if (header == '') {
      _state = _State.content;
    }

    final contentLengthMatch = _contentLengthRe.matchAsPrefix(header);
    if (contentLengthMatch != null) {
      _contentLength = int.parse(contentLengthMatch.group(1)!);
      return;
    }
  }

  void _tryParseContent() {
    if (_unparsed.length >= _contentLength!) {
      _parseContent();
    }
  }

  void _parseContent() {
    final content = _unparsed.substring(0, _contentLength);
    _unparsed = _unparsed.substring(_contentLength!);
    _contentLength = null;
    _state = _State.headers;
    _onContent(content);
  }

  void _onContent(String content) {
    final Map<String, dynamic> map;

    try {
      map = jsonDecode(content);
      // ignore: avoid_catches_without_on_clauses
    } catch (ex) {
      print('Cannot decode JSON: $content'); // ignore: avoid_print
      rethrow;
    }

    _onMap(map);
  }

  void _onMap(Map<String, dynamic> map) {
    final id = map['id'];
    if (id != null) {
      _onResponse(id, map);
      return;
    }

    final method = map['method'];
    if (method != null) {
      _onNotification(method, map);
      return;
    }

    throw Exception('Unknown message type: $map');
  }

  void _onResponse(int id, Map<String, dynamic> map) {
    final completer = _completers[id];

    if (completer == null) {
      throw Exception('Received a response without request: id=$id, $map');
    }

    _completers.remove(id);
    final result = map['result'];
    completer.complete(result);
  }

  void _onNotification(String method, Map<String, dynamic> map) {
    for (final listener in _listeners) {
      listener.onNotification(method, map);
    }
  }

  @override
  void onError(List<int> error) {
    final str = String.fromCharCodes(error);
    print('Error: $str'); // ignore: avoid_print
  }

  /// Shuts down the server.
  Future<void> dispose() async {
    await _rawClient.dispose();
  }
}

enum _State {
  headers,
  content,
}

/// A listener for [LspMapClient].
class LspMapListener {
  /// Called when a notification from server is received (not a response).
  ///
  /// [map] is the full response map including [method].
  void onNotification(String method, Map<String, dynamic> map) {}
}
