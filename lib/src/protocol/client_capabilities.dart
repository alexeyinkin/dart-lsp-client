import 'package:json_annotation/json_annotation.dart';

part 'client_capabilities.g.dart';

/// The list of capabilities of the client.
@JsonSerializable(createFactory: false)
class ClientCapabilities {
  // ignore: public_member_api_docs
  const ClientCapabilities({
    this.experimental,
  });

  /// Custom capabilities. These are experimental and subject to change,
  /// hence they are specified as a raw map.
  final Map<String, dynamic>? experimental;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => _$ClientCapabilitiesToJson(this);
}
