import 'dart:io';

import 'package:meta/meta.dart';

/// Low-level LSP client. Writes strings and notifies on the data received.
class LspRawClient {
  final _listeners = <LspRawListener>[];
  Process? _process;

  /// Launches the server and connects to it.
  Future<void> start() async {
    final process = await Process.start('dart', [
      'language-server',
      '--client-id=my-editor.my-plugin',
      '--client-version=3.17',
      '--enable-experiment=macros',
    ]);

    process.stdout.listen(onData);
    process.stderr.listen(onError);
    _process = process;
  }

  /// Called to dispatch the [data] to the listeners.
  @internal
  void onData(List<int> data) {
    for (final listener in _listeners) {
      listener.onData(data);
    }
  }

  /// Called to dispatch the [error] to the listeners.
  @internal
  void onError(List<int> error) {
    for (final listener in _listeners) {
      listener.onError(error);
    }
  }

  /// Adds the [listener].
  void addListener(LspRawListener listener) {
    _listeners.add(listener);
  }

  /// Writes [str] to the server's stdin.
  void writeString(String str) {
    for (final listener in _listeners) {
      listener.beforeWriteString(str);
    }
    _process!.stdin.write(str);
  }

  /// Shuts down the server.
  Future<void> dispose() async {
    _process!.kill(ProcessSignal.sigint);
    await _process!.exitCode;
  }
}

/// A listener for [LspRawClient].
class LspRawListener {
  /// Called when any piece of data is received from the server's stdout.
  void onData(List<int> data) {}

  /// Called when any piece of data is received from the server's stderr.
  void onError(List<int> error) {}

  /// Called before writing [str] to the server's stdin.
  void beforeWriteString(String str) {}
}

/// A listener for [LspRawClient] that logs input and output (but not stderr).
class LspRawPrintListener extends LspRawListener {
  @override
  void onData(List<int> data) {
    final str = String.fromCharCodes(data);
    print('Received ${str.length} characters: ┤$str├'); // ignore: avoid_print
  }

  @override
  void beforeWriteString(String str) {
    print('Writing ${str.length} characters: ┤$str├'); // ignore: avoid_print
  }
}
