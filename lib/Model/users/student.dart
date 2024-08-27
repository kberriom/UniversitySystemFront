import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/grade.dart';
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
      super.lastName.toLowerCase(),
      super.governmentId.toLowerCase(),
    ]);
  }
}

@MappableClass()
class StudentDto with StudentDtoMappable {
  String? name;
  String? lastName;
  String? mobilePhone;
  String? landPhone;

  StudentDto({
    this.name,
    this.lastName,
    this.mobilePhone,
    this.landPhone,
  });

  static const fromMap = StudentDtoMapper.fromMap;
  static const fromJson = StudentDtoMapper.fromJson;
}

@MappableClass()
class StudentSubjectRegistration with StudentSubjectRegistrationMappable {
  StudentSubjectRegistrationId id;
  String registrationDate;
  double finalGrade;
  Set<Grade>? subjectGrades;

  static const fromMap = StudentSubjectRegistrationMapper.fromMap;
  static const fromJson = StudentSubjectRegistrationMapper.fromJson;

  StudentSubjectRegistration({required this.id, required this.registrationDate, required this.finalGrade, this.subjectGrades});
}

@MappableClass()
class StudentSubjectRegistrationId with StudentSubjectRegistrationIdMappable {
  int studentUserId;
  int subjectId;

  static const fromMap = StudentSubjectRegistrationIdMapper.fromMap;
  static const fromJson = StudentSubjectRegistrationIdMapper.fromJson;

  StudentSubjectRegistrationId({required this.studentUserId, required this.subjectId});
}
