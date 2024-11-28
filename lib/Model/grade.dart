import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/uni_system_model.dart';
import 'package:university_system_front/Model/users/student.dart';

part 'grade.mapper.dart';

@MappableClass()
class Grade with GradeMappable implements UniSystemModel<int> {
  @override
  int id;
  String gradeValue;
  String percentageOfFinalGrade;
  StudentSubjectRegistrationId registrationId;
  String description;

  Grade({required this.id, required this.gradeValue, required this.percentageOfFinalGrade,required this.registrationId , required this.description});

  static const fromMap = GradeMapper.fromMap;
  static const fromJson = GradeMapper.fromJson;

  @override
  bool hasNumberMatch(num search) {
    return search.toStringAsFixed(2) == gradeValue || search.toStringAsFixed(2) == percentageOfFinalGrade;
  }

  @override
  bool hasStringMatch(String search) {
    return bestMatch(search: search, stringList: [
      description.toLowerCase(),
    ]);
  }
}

@MappableClass()
class GradeDto with GradeDtoMappable {
  String? gradeValue;
  String? percentageOfFinalGrade;
  String? description;

  static const fromMap = GradeDtoMapper.fromMap;
  static const fromJson = GradeDtoMapper.fromJson;

  GradeDto({this.gradeValue, this.percentageOfFinalGrade, this.description});
}
