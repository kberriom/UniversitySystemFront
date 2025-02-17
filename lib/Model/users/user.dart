import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/uni_system_model.dart';

part 'user.mapper.dart';

@MappableClass(discriminatorKey: 'UserRole')
abstract class User with UserMappable implements UniSystemModel<int> {
  @override
  int id;
  String name;
  String lastName;
  String governmentId;
  String email;
  String? mobilePhone;
  String? landPhone;
  String birthdate;
  String username;
  String enrollmentDate;
  String role;

  User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.governmentId,
    required this.email,
    this.mobilePhone,
    this.landPhone,
    required this.birthdate,
    required this.username,
    required this.enrollmentDate,
    required this.role,
  });

  UserRole getUserRole() {
    return UserRole.values.firstWhere((posibleRole) => posibleRole.roleName == role);
  }

  void setUserRole(UserRole userRole) {
    role = userRole.name;
  }
}

@MappableClass()
class AdminPasswordUpdateDto with AdminPasswordUpdateDtoMappable {
  String email;
  String newPassword;

  AdminPasswordUpdateDto({
    required this.email,
    required this.newPassword,
  });

  static const fromMap = AdminPasswordUpdateDtoMapper.fromMap;
  static const fromJson = AdminPasswordUpdateDtoMapper.fromJson;
}
