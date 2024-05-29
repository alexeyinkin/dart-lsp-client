import 'dart:io';

import 'package:lsp_client/lsp_client.dart';
import 'package:test/test.dart';

const _delay = Duration(milliseconds: 500);

void main() {
  test('Real', () async {
    final pwd = Directory.current.path;

    final rawClient = LspRawClient();
    rawClient.addListener(LspRawPrintListener());

    final client = LspClient(
      rawClient: rawClient,
    );
    await client.start();

    final initializeResult = await client.initialize(
      InitializeParams(
        rootUri: 'file://$pwd/example',
        capabilities: const ClientCapabilities(
          experimental: {
            'supportsDartTextDocumentContentProvider': true,
          },
        ),
      ),
    );

    expect(initializeResult, isA<InitializeResult>());

    final initializedFuture = client.initialized();
    final analyzedFuture = client.awaitAnalyzed();

    await (initializedFuture, analyzedFuture).wait;

    final contentResult = await client.dartTextDocumentContent(
      DartTextDocumentContentParams(
        uri: 'dart-macro+file://$pwd/example/lib/hello_client.dart',
      ),
    );

    expect(
      contentResult.content,
      File('test/hello_client_augmentation.dart.txt').readAsStringSync(),
    );
  });

  test('Merges, splits, and denormalizes messages correctly', () async {
    final client = LspClient(
      rawClient: LspRawClientMock(),
    );

    await client.start();

    final initializeResult = await client.initialize(
      const InitializeParams(
        capabilities: ClientCapabilities(),
      ),
    );

    expect(initializeResult, isA<InitializeResult>());

    await client.initialized();
  });
}

class LspRawClientMock extends LspRawClient {
  int sentMessageCount = 0;

  static const initializeResponse = 'Content-Length: 2460\r\n'
      'Content-Type: application/vscode-jsonrpc; charset=utf-8\r\n'
      '\r\n'
      r'''{"id":1,"jsonrpc":"2.0","result":{"capabilities":{"callHierarchyProvider":true,"codeActionProvider":true,"codeLensProvider":{},"colorProvider":{"documentSelector":[{"language":"dart","scheme":"file"}]},"completionProvider":{"completionItem":{"labelDetailsSupport":true},"resolveProvider":true,"triggerCharacters":[".","=","(","$","\"","'","{","/",":"]},"definitionProvider":true,"documentFormattingProvider":true,"documentHighlightProvider":true,"documentLinkProvider":{"resolveProvider":false},"documentOnTypeFormattingProvider":{"firstTriggerCharacter":"}","moreTriggerCharacter":[";"]},"documentRangeFormattingProvider":true,"documentSymbolProvider":true,"executeCommandProvider":{"commands":["dart.edit.sortMembers","dart.edit.organizeImports","dart.edit.fixAll","dart.edit.fixAllInWorkspace.preview","dart.edit.fixAllInWorkspace","dart.edit.sendWorkspaceEdit","refactor.perform","refactor.validate","dart.logAction","dart.refactor.convert_all_formal_parameters_to_named","dart.refactor.convert_selected_formal_parameters_to_named","dart.refactor.move_selected_formal_parameters_left","dart.refactor.move_top_level_to_file"],"workDoneProgress":true},"experimental":{"textDocument":{"super":{},"augmented":{},"augmentation":{}}},"foldingRangeProvider":true,"hoverProvider":true,"implementationProvider":true,"inlayHintProvider":{"resolveProvider":false},"referencesProvider":true,"renameProvider":true,"selectionRangeProvider":true,"semanticTokensProvider":{"full":{"delta":false},"legend":{"tokenModifiers":["documentation","constructor","declaration","importPrefix","instance","static","escape","annotation","control","label","interpolation","void"],"tokenTypes":["annotation","keyword","class","comment","method","variable","parameter","enum","enumMember","type","source","property","namespace","boolean","number","string","function","typeParameter"]},"range":true},"signatureHelpProvider":{"retriggerCharacters":[","],"triggerCharacters":["("]},"textDocumentSync":{"change":2,"openClose":true,"willSave":false,"willSaveWaitUntil":false},"typeDefinitionProvider":true,"typeHierarchyProvider":true,"workspace":{"fileOperations":{"willRename":{"filters":[{"pattern":{"glob":"**/*.dart","matches":"file"},"scheme":"file"},{"pattern":{"glob":"**/","matches":"folder"},"scheme":"file"}]}},"workspaceFolders":{"changeNotifications":true,"supported":true}},"workspaceSymbolProvider":true},"serverInfo":{"name":"Dart SDK LSP Analysis Server","version":"3.4.0"}}}''';

  static const initializedResponse = 'Content-Length: 38\r\n'
      'Content-Type: application/vscode-jsonrpc; charset=utf-8\r\n'
      '\r\n'
      '{"id":2,"jsonrpc":"2.0","result":null}';

  @override
  Future<void> start() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> writeString(String str) async {
    switch (sentMessageCount) {
      case 0: // initialize
        await Future.delayed(_delay);
        // Content-Length: 2460\r
        onData(
          initializeResponse.substring(0, 21).codeUnits,
        );

        await Future.delayed(_delay);
        // \nContent-
        onData(
          initializeResponse.substring(21, 30).codeUnits,
        );

        await Future.delayed(_delay);
        // Type: application/...
        onData(
          initializeResponse.substring(30, 500).codeUnits,
        );

        await Future.delayed(_delay);
        onData(
          initializeResponse.substring(500).codeUnits,
        );

      case 1: // initialized
        await Future.delayed(_delay);
        onData(
          initializedResponse.codeUnits,
        );
    }

    sentMessageCount++;
  }
}
