import 'package:freezed_annotation/freezed_annotation.dart';

part 'bearer_token.freezed.dart';

part 'bearer_token.g.dart';

@freezed
class BearerToken with _$BearerToken {
  const factory BearerToken({required String token, UserRole? role, bool? mustRedirectLogin}) = _BearerToken;

  factory BearerToken.fromJson(Map<String, dynamic> json) => _$BearerTokenFromJson(json);
}

enum BearerTokenType {
  jwt(name: "jwt");

  final String name;

  const BearerTokenType({required this.name});
}

enum UserRole {
  admin(roleName: "ROLE_ADMIN"),
  teacher(roleName: "ROLE_TEACHER"),
  student(roleName: "ROLE_STUDENT");

  final String roleName;

  const UserRole({required this.roleName});
}
