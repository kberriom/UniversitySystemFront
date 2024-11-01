import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Repository/grade/grade_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';

part 'grade_repository.g.dart';

@Riverpod(keepAlive: true)
GradeRepositoryImpl gradeRepositoryImpl(Ref ref) {
  return GradeRepositoryImpl(ref);
}

class GradeRepositoryImpl implements GradeRepository {
  late final UniSystemApiService uniSystemApiService;

  GradeRepositoryImpl(Ref ref) {
    uniSystemApiService = UniSystemApiService(ref);
  }

  @override
  Future<StudentSubjectRegistration> addStudentGrade(int subjectId, int studentId, GradeDto gradeDto) {
    // TODO: implement addStudentGrade
    throw UnimplementedError();
  }

  @override
  Future<List<List<Grade>>> getAllStudentAllGrades() {
    // TODO: implement getAllStudentAllGrades
    throw UnimplementedError();
  }

  @override
  Future<List<List<Grade>>> getAllStudentAllGradesInSubject(int subjectId) {
    // TODO: implement getAllStudentAllGradesInSubject
    throw UnimplementedError();
  }

  @override
  Future<List<Grade>> getMyGrade(BearerToken selfIdentityToken) {
    // TODO: implement getMyGrade
    throw UnimplementedError();
  }

  @override
  Future<List<Grade>> getOneStudentGrades(int subjectId, int studentId) {
    // TODO: implement getOneStudentGrades
    throw UnimplementedError();
  }

  @override
  Future<StudentSubjectRegistration> modifyStudentGrade(int subjectId, int studentId, int gradeId, GradeDto gradeDto) {
    // TODO: implement modifyStudentGrade
    throw UnimplementedError();
  }

  @override
  Future<void> removeStudentGrade(int subjectId, int studentId, int gradeId) {
    // TODO: implement removeStudentGrade
    throw UnimplementedError();
  }

  @override
  Future<StudentSubjectRegistration> setStudentFinalGrade(int subjectId, int studentId, double finalGrade) {
    // TODO: implement setStudentFinalGrade
    throw UnimplementedError();
  }

  @override
  Future<StudentSubjectRegistration> setStudentFinalGradeAuto(int subjectId, int studentId) {
    // TODO: implement setStudentFinalGradeAuto
    throw UnimplementedError();
  }
}
