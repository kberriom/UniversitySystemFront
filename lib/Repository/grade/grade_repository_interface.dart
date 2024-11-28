import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Model/users/student.dart';

abstract interface class GradeRepository {
  Future<StudentSubjectRegistration> setStudentFinalGrade(int subjectId, int studentId, String finalGrade);

  Future<StudentSubjectRegistration> setStudentFinalGradeAuto(int subjectId, int studentId);

  Future<StudentSubjectRegistration> addStudentGrade(int subjectId, int studentId, GradeDto gradeDto);

  Future<StudentSubjectRegistration> modifyStudentGrade(int subjectId, int studentId, int gradeId, GradeDto gradeDto);

  Future<StudentSubjectRegistration> getStudentSubjectRegistration(int subjectId, int studentId);

  Future<List<Grade>> getOneStudentGrades(int subjectId, int studentId);

  ///URL param [subjectName]
  Future<List<Grade>> getMyGrade(BearerToken selfIdentityToken);

  Future<List<List<Grade>>> getAllStudentAllGrades();

  Future<List<List<Grade>>> getAllStudentAllGradesInSubject(int subjectId);

  Future<void> removeStudentGrade(int subjectId, int studentId, int gradeId);

  Future<void> deleteStudentFinalGrade(int subjectId, int studentId);
}
