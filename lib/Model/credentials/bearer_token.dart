import 'package:freezed_annotation/freezed_annotation.dart';

part 'bearer_token.freezed.dart';
part 'bearer_token.g.dart';

@freezed
class BearerToken with _$BearerToken {
  const factory BearerToken({required String token, bool? mustRedirectLogin}) = _BearerToken;

  factory BearerToken.fromJson(Map<String, dynamic> json) => _$BearerTokenFromJson(json);
}
