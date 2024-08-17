import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:string_similarity/string_similarity.dart';

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
    final match = search.bestMatch([
      super.name.toLowerCase(),
      super.lastName.toLowerCase(),
      super.governmentId.toLowerCase(),
      department.toLowerCase(),
    ]);
    return (match.bestMatch.rating ?? 0) > 0.6;
  }
}

@MappableClass()
class TeacherDto with TeacherDtoMappable {
  String? name;
  String? lastName;
  String? mobilePhone;
  String? landPhone;
  String? department;

  TeacherDto({
    this.name,
    this.lastName,
    this.mobilePhone,
    this.landPhone,
  });

  static const fromMap = TeacherDtoMapper.fromMap;
  static const fromJson = TeacherDtoMapper.fromJson;
}
