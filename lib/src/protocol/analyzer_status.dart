import 'package:json_annotation/json_annotation.dart';

part 'analyzer_status.g.dart';

/// '$/analyzerStatus' Notification.
@JsonSerializable(createToJson: false)
class AnalyzerStatusParams {
  // ignore: public_member_api_docs
  const AnalyzerStatusParams({
    required this.isAnalyzing,
  });

  // ignore: public_member_api_docs
  final bool isAnalyzing;

  // ignore: public_member_api_docs
  factory AnalyzerStatusParams.fromJson(Map<String, dynamic> map) =>
      _$AnalyzerStatusParamsFromJson(map);
}
