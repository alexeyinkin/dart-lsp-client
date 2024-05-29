import 'package:json_annotation/json_annotation.dart';

import 'client_capabilities.dart';

part 'initialize.g.dart';

/// 'initialize' Method.
@JsonSerializable(createFactory: false)
class InitializeParams {
  // ignore: public_member_api_docs
  const InitializeParams({
    required this.capabilities,
    this.processId,
    this.rootUri,
  });

  // ignore: public_member_api_docs
  final int? processId;

  // ignore: public_member_api_docs
  final String? rootUri;

  // ignore: public_member_api_docs
  final ClientCapabilities capabilities;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => _$InitializeParamsToJson(this);
}

/// 'initialize' Result.
@JsonSerializable(createToJson: false)
class InitializeResult {
  // ignore: public_member_api_docs
  const InitializeResult();

  // ignore: public_member_api_docs
  factory InitializeResult.fromJson(Map<String, dynamic> map) =>
      _$InitializeResultFromJson(map);
}
