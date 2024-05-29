import 'dart:async';

import 'map_client.dart';
import 'protocol/analyzer_status.dart';
import 'protocol/dart_text_document_content.dart';
import 'protocol/initialize.dart';
import 'raw_client.dart';

/// High-level client for LSP.
class LspClient extends LspMapListener {
  // ignore: public_member_api_docs
  LspClient({
    LspRawClient? rawClient,
  }) : _mapClient = LspMapClient(rawClient: rawClient) {
    _mapClient.addListener(this);
  }

  final _listeners = <LspListener>[];
  final LspMapClient _mapClient;

  Completer _awaitAnalyzedCompleter = Completer();

  /// Launches the server and connects to it.
  Future<void> start() async {
    await _mapClient.start();
  }

  /// Completes until the analysis is (started and) finished.
  Future<void> awaitAnalyzed() async {
    return _awaitAnalyzedCompleter.future;
  }

  /// Calls 'dart/textDocumentContent' method.
  Future<DartTextDocumentContentResult> dartTextDocumentContent(
    DartTextDocumentContentParams params,
  ) async {
    final map = await _mapClient.send(
      'dart/textDocumentContent',
      params.toJson(),
    );
    return DartTextDocumentContentResult.fromJson(map);
  }

  /// Calls 'initialize' method.
  Future<InitializeResult> initialize(InitializeParams params) async {
    final map = await _mapClient.send('initialize', params.toJson());
    return InitializeResult.fromJson(map);
  }

  /// Calls 'initialized' method.
  Future<void> initialized() async {
    await _mapClient.send('initialized', {});
  }

  /// Adds the [listener].
  void addListener(LspListener listener) {
    _listeners.add(listener);
  }

  @override
  void onNotification(String method, Map<String, dynamic> map) {
    final params = map['params'];

    for (final listener in _listeners) {
      listener.onMapNotification(method, map);
    }

    switch (method) {
      case r'$/analyzerStatus':
        final obj = AnalyzerStatusParams.fromJson(params);
        _onAnalyzerStatus(obj);
    }
  }

  void _onAnalyzerStatus(AnalyzerStatusParams params) {
    if (!params.isAnalyzing) {
      _awaitAnalyzedCompleter.complete();
      _awaitAnalyzedCompleter = Completer();
    }

    for (final listener in _listeners) {
      listener.onAnalyzerStatus(params);
    }
  }

  /// Shuts down the server.
  Future<void> dispose() async {
    await _mapClient.dispose();
  }
}

/// A listener for [LspClient].
class LspListener {
  /// Called on '$/analyzerStatus' notification.
  void onAnalyzerStatus(AnalyzerStatusParams params) {}

  /// Called on all notifications.
  ///
  /// [map] is the full response map including [method].
  void onMapNotification(String method, Map<String, dynamic> map) {}
}