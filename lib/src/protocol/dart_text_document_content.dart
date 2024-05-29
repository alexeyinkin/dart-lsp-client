import 'package:json_annotation/json_annotation.dart';

part 'dart_text_document_content.g.dart';

/// 'dart/textDocumentContent' Method.
@JsonSerializable(createFactory: false)
class DartTextDocumentContentParams {
  // ignore: public_member_api_docs
  const DartTextDocumentContentParams({
    required this.uri,
  });

  // ignore: public_member_api_docs
  final String uri;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => _$DartTextDocumentContentParamsToJson(this);
}

/// 'dart/textDocumentContent' Result.
@JsonSerializable(createToJson: false)
class DartTextDocumentContentResult {
  // ignore: public_member_api_docs
  const DartTextDocumentContentResult({
    required this.content,
  });

  // ignore: public_member_api_docs
  final String content;

  // ignore: public_member_api_docs
  factory DartTextDocumentContentResult.fromJson(Map<String, dynamic> map) =>
      _$DartTextDocumentContentResultFromJson(map);
}
