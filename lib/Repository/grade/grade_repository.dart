import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Repository/grade/grade_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';
import 'package:university_system_front/Util/provider_utils.dart';

part 'grade_repository.g.dart';

@Riverpod(keepAlive: true)
GradeRepository gradeRepository(Ref ref) {
  ref.keepFor(const Duration(minutes: 20));
  return _GradeRepositoryImpl(ref);
}

class _GradeRepositoryImpl implements GradeRepository {
  late final UniSystemApiService _uniSystemApiService;

  _GradeRepositoryImpl(Ref ref) {
    _uniSystemApiService = UniSystemApiService(ref);
  }

  @override
  Future<StudentSubjectRegistration> addStudentGrade(int subjectId, int studentId, GradeDto gradeDto) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.post,
      body: gradeDto.toMap(),
      query: {"subjectId": subjectId.toString(), "studentId": studentId.toString()},
      endpoint: 'grade/addStudentGrade',
      includeResponseBodyOnException: true,
    );
    Json response = await _uniSystemApiService.makeRequest(request);
    return StudentSubjectRegistration.fromMap(response);
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
  Future<List<Grade>> getOneStudentGrades(int subjectId, int studentId) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.get,
      endpoint: 'grade/getOneStudentGrades',
      query: {
        "subjectId": subjectId.toString(),
        "studentId": studentId.toString(),
      },
    );
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    List<Grade> list = [];
    for (var gradeJson in response) {
      list.add(Grade.fromMap(gradeJson));
    }
    return list;
  }

  @override
  Future<StudentSubjectRegistration> modifyStudentGrade(int subjectId, int studentId, int gradeId, GradeDto gradeDto) {
    // TODO: implement modifyStudentGrade
    throw UnimplementedError();
  }

  @override
  Future<StudentSubjectRegistration> getStudentSubjectRegistration(int subjectId, int studentId) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.get,
      query: {
        "subjectId": subjectId.toString(),
        "studentId": studentId.toString(),
      },
      endpoint: 'grade/getStudentSubjectRegistration',
    );
    Json response = await _uniSystemApiService.makeRequest(request);
    return StudentSubjectRegistration.fromMap(response);
  }

  @override
  Future<void> removeStudentGrade(int subjectId, int studentId, int gradeId) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.delete,
      query: {
        "subjectId": subjectId.toString(),
        "studentId": studentId.toString(),
        "gradeId": gradeId.toString(),
      },
      endpoint: 'grade/removeStudentGrade',
    );
    return await _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<StudentSubjectRegistration> setStudentFinalGrade(int subjectId, int studentId, String finalGrade) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.put,
      query: {
        "subjectId": subjectId.toString(),
        "studentId": studentId.toString(),
        "finalGrade": finalGrade,
      },
      endpoint: 'grade/setStudentFinalGrade',
    );
    Json response = await _uniSystemApiService.makeRequest(request);
    return StudentSubjectRegistration.fromMap(response);
  }

  @override
  Future<StudentSubjectRegistration> setStudentFinalGradeAuto(int subjectId, int studentId) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.put,
      query: {
        "subjectId": subjectId.toString(),
        "studentId": studentId.toString(),
      },
      endpoint: 'grade/setStudentFinalGradeAuto',
    );
    Json response = await _uniSystemApiService.makeRequest(request);
    return StudentSubjectRegistration.fromMap(response);
  }

  @override
  Future<void> deleteStudentFinalGrade(int subjectId, int studentId) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.delete,
      query: {
        "subjectId": subjectId.toString(),
        "studentId": studentId.toString(),
      },
      endpoint: 'grade/deleteStudentFinalGrade',
    );
    return await _uniSystemApiService.makeRequest(request);
  }
}
