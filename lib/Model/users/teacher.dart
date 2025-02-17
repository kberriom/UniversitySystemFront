import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/uni_system_model.dart';
import 'package:university_system_front/Model/users/user.dart';

part 'teacher.mapper.dart';

@MappableClass(discriminatorValue: UserRole.teacher)
class Teacher extends User with TeacherMappable {
  String department;

  Teacher(
      {required super.id,
      required super.name,
      required super.lastName,
      required super.governmentId,
      required super.email,
      super.mobilePhone,
      super.landPhone,
      required super.birthdate,
      required super.username,
      required super.enrollmentDate,
      required this.department,
      required super.role});

  static const fromMap = TeacherMapper.fromMap;
  static const fromJson = TeacherMapper.fromJson;

  @override
  bool hasNumberMatch(num search) {
    return super.id == search;
  }

  @override
  bool hasStringMatch(String search) {
    return bestMatch(search: search, stringList: [
      super.name.toLowerCase(),
      super.lastName.toLowerCase(),
      super.email.toLowerCase(),
      super.governmentId.toLowerCase(),
      department.toLowerCase(),
    ]);
  }
}

@MappableClass()
class TeacherUpdateDto with TeacherUpdateDtoMappable {
  String? name;
  String? lastName;
  String? mobilePhone;
  String? landPhone;
  String? department;

  TeacherUpdateDto({
    this.name,
    this.lastName,
    this.mobilePhone,
    this.landPhone,
    this.department,
  });

  static const fromMap = TeacherUpdateDtoMapper.fromMap;
  static const fromJson = TeacherUpdateDtoMapper.fromJson;
}

@MappableClass()
class TeacherCreationDto with TeacherCreationDtoMappable {
  String name;
  String lastName;
  String governmentId;
  String email;
  String? mobilePhone;
  String? landPhone;
  String birthdate;
  String username;
  String department;
  String userPassword;

  TeacherCreationDto({
    required this.name,
    required this.lastName,
    required this.governmentId,
    required this.email,
    this.mobilePhone,
    this.landPhone,
    required this.birthdate,
    required this.username,
    required this.department,
    required this.userPassword,
  });

  static const fromMap = TeacherCreationDtoMapper.fromMap;
  static const fromJson = TeacherCreationDtoMapper.fromJson;
}

@MappableClass()
class TeacherAssignation with TeacherAssignationMappable {
  TeacherAssignationId id;
  String roleInClass;

  static const fromMap = TeacherAssignationMapper.fromMap;
  static const fromJson = TeacherAssignationMapper.fromJson;

  TeacherAssignation({required this.id, required this.roleInClass});
}

@MappableClass()
class TeacherAssignationId with TeacherAssignationIdMappable {
  int subjectId;
  int teacherUserId;

  static const fromMap = TeacherAssignationIdMapper.fromMap;
  static const fromJson = TeacherAssignationIdMapper.fromJson;

  TeacherAssignationId({required this.subjectId, required this.teacherUserId});
}
