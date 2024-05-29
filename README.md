This package implements a tiny subset of
[Language Server Protocol](https://microsoft.github.io/language-server-protocol/).
It starts and connects to a local instance of Dart Language Server
and allows you to call its methods.

The purpose was to get the code generated by Dart experimental macros,
so this package currently supports the minimal set of API to do that.

It's a shame that this package exists
because Dart SDK already has
[all the API generated from the protocol specification](https://github.com/dart-lang/sdk/tree/main/third_party/pkg/language_server_protocol),
but that package is not published on pub.dev and so it's hard to reuse.

If you need more than this trivial client,
consider filing an issue with Dart SDK and ask them to publish their comprehensive package.

# Usage

```dart
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
```

If you need an LSP client for different purposes
you can help expand this package or use a lower-level `LspMapClient`.
That lower-level client operates on maps and does not normalize or denormalize messages,
and is thus capable of handling all messages and notifications in LSP.
