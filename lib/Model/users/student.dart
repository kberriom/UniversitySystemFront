import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/uni_system_model.dart';
import 'package:university_system_front/Model/users/user.dart';

part 'student.mapper.dart';

@MappableClass(discriminatorValue: UserRole.student)
class Student extends User with StudentMappable {
  Student(
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
      required super.role});

  static const fromMap = StudentMapper.fromMap;
  static const fromJson = StudentMapper.fromJson;

  @override
  bool hasNumberMatch(num search) {
    return super.id == search;
  }

  @override
  bool hasStringMatch(String search) {
    return bestMatch(search: search, stringList: [
      super.name.toLowerCase(),
      super.email.toLowerCase(),
      super.lastName.toLowerCase(),
      super.governmentId.toLowerCase(),
    ]);
  }
}

@MappableClass()
class StudentUpdateDto with StudentUpdateDtoMappable {
  String? name;
  String? lastName;
  String? mobilePhone;
  String? landPhone;

  StudentUpdateDto({
    this.name,
    this.lastName,
    this.mobilePhone,
    this.landPhone,
  });

  static const fromMap = StudentUpdateDtoMapper.fromMap;
  static const fromJson = StudentUpdateDtoMapper.fromJson;
}

@MappableClass()
class StudentCreationDto with StudentCreationDtoMappable {
  String name;
  String lastName;
  String governmentId;
  String email;
  String? mobilePhone;
  String? landPhone;
  String birthdate;
  String username;
  String userPassword;

  StudentCreationDto({
    required this.name,
    required this.lastName,
    required this.governmentId,
    required this.email,
    this.mobilePhone,
    this.landPhone,
    required this.birthdate,
    required this.username,
    required this.userPassword,
  });

  static const fromMap = StudentCreationDtoMapper.fromMap;
  static const fromJson = StudentCreationDtoMapper.fromJson;
}

@MappableClass()
class StudentSubjectRegistration with StudentSubjectRegistrationMappable {
  StudentSubjectRegistrationId id;
  String registrationDate;
  String? finalGrade;
  Set<Grade>? subjectGrades;

  ///Internal attribute only
  Subject? subject;

  static const fromMap = StudentSubjectRegistrationMapper.fromMap;
  static const fromJson = StudentSubjectRegistrationMapper.fromJson;

  StudentSubjectRegistration({
    required this.id,
    required this.registrationDate,
    this.finalGrade,
    this.subjectGrades,
    this.subject,
  });
}

@MappableClass()
class StudentSubjectRegistrationId with StudentSubjectRegistrationIdMappable {
  int studentUserId;
  int subjectId;

  static const fromMap = StudentSubjectRegistrationIdMapper.fromMap;
  static const fromJson = StudentSubjectRegistrationIdMapper.fromJson;

  StudentSubjectRegistrationId({required this.studentUserId, required this.subjectId});
}
