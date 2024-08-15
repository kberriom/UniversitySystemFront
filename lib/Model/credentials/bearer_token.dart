import 'package:freezed_annotation/freezed_annotation.dart';

part 'bearer_token.freezed.dart';

part 'bearer_token.g.dart';

@freezed
///Internal token representation that contains the current user login state
///If a bearer token has a role it implies that the token is valid.
///
///A [token] can be:
///- "" : representing no token has been saved in storage
///- "<TOKEN>" representing a token in _any_ state, even expired
///- "signOut" indicating a user initiated sign out event or unexpected token expiration by server
///
/// [mustRedirectTokenExpired] serves to disambiguate the [token] state,
/// if true it means the value of token is expired or invalid and is saved in storage
///
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
