import 'package:freezed_annotation/freezed_annotation.dart';

part 'bearer_token.freezed.dart';

part 'bearer_token.g.dart';

@freezed
class BearerToken with _$BearerToken {
  const factory BearerToken({required String token, UserRole? role, bool? mustRedirectTokenExpired}) = _BearerToken;

  factory BearerToken.fromJson(Map<String, dynamic> json) => _$BearerTokenFromJson(json);
}

enum InternalTokenMessage {
  signOut;
}

enum BearerTokenType {
  jwt;
}

enum UserRole {
  admin(roleName: "ROLE_ADMIN"),
  teacher(roleName: "ROLE_TEACHER"),
  student(roleName: "ROLE_STUDENT");

  final String roleName;

  const UserRole({required this.roleName});
}
