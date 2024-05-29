import 'dart:io';

import 'package:lsp_client/lsp_client.dart';

Future<void> main() async {
  final pwd = Directory.current.path;

  final client = LspClient();
  await client.start();

  await client.initialize(
    InitializeParams(
      rootUri: 'file://$pwd',
      capabilities: const ClientCapabilities(
        experimental: {
          'supportsDartTextDocumentContentProvider': true,
        },
      ),
    ),
  );

  final initializedFuture = client.initialized();
  final analyzedFuture = client.awaitAnalyzed();
  await (initializedFuture, analyzedFuture).wait;

  final contentResult = await client.dartTextDocumentContent(
    DartTextDocumentContentParams(
      uri: 'dart-macro+file://$pwd/lib/hello_client.dart',
    ),
  );

  print(contentResult.content); // ignore: avoid_print
  await client.dispose();
}
