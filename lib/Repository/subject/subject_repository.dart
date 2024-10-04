import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Repository/subject/subject_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';
import 'package:university_system_front/Util/provider_utils.dart';

part 'subject_repository.g.dart';

@riverpod
SubjectRepository subjectRepository(SubjectRepositoryRef ref) {
  ref.keepFor(const Duration(minutes: 20));
  return _SubjectRepositoryImpl(ref);
}

class _SubjectRepositoryImpl implements SubjectRepository {
  late final UniSystemApiService _uniSystemApiService;

  _SubjectRepositoryImpl(Ref ref) {
    _uniSystemApiService = UniSystemApiService(ref);
  }

  @override
  Future<StudentSubjectRegistration> addStudent(int studentId, String subjectName) async {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.post,
        query: {"subjectName": subjectName, "studentId": studentId.toString()},
        endpoint: 'subject/addStudent');
    Json response = await _uniSystemApiService.makeRequest(request);
    return StudentSubjectRegistration.fromMap(response);
  }

  @override
  Future<TeacherAssignation> addTeacher(int teacherId, String subjectName, String roleInClass) async {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.put,
        query: {"subjectName": subjectName, "teacherId": teacherId.toString(), "roleInClass": roleInClass},
        endpoint: 'subject/addTeacher');
    Json response = await _uniSystemApiService.makeRequest(request);
    return TeacherAssignation.fromMap(response);
  }

  @override
  Future<Subject> createSubject(SubjectDto subjectDto) async {
    final request =
        UniSystemRequest(type: UniSysApiRequestType.post, body: subjectDto.toMap(), endpoint: 'subject/createSubject');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Subject.fromMap(response);
  }

  @override
  Future<void> deleteSubject(String subjectName) async {
    final request =
        UniSystemRequest(type: UniSysApiRequestType.delete, query: {"name": subjectName}, endpoint: 'subject/deleteSubject');
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<List<StudentSubjectRegistration>> getAllRegisteredStudents(String subjectName) async {
    final request = UniSystemRequest(type: UniSysApiRequestType.get, endpoint: 'subject/getAllRegisteredStudents/$subjectName');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    List<StudentSubjectRegistration> list = [];
    for (var registrationJson in response) {
      list.add(StudentSubjectRegistration.fromMap(registrationJson));
    }
    return list;
  }

  @override
  Future<List<Subject>> getAllSubjects() async {
    const request = UniSystemRequest(type: UniSysApiRequestType.get, endpoint: 'subject/getAllSubjects');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    List<Subject> list = [];
    for (var subjectJson in response) {
      list.add(Subject.fromMap(subjectJson));
    }
    return list;
  }

  @override
  Future<PaginatedList<Subject>> getAllSubjectsPaged(int page, int size) async {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.get,
        query: {"page": page.toString(), "size": size.toString()},
        endpoint: 'subject/getAllSubjects/paged');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    PageInfo pageInfo = PageInfo.fromMap(response[0]);
    response.removeAt(0);
    Set<Subject> set = {};
    for (var subjectJson in response) {
      set.add(Subject.fromMap(subjectJson));
    }
    return PaginatedList<Subject>(pageInfo: pageInfo, set: set);
  }

  @override
  Future<List<TeacherAssignation>> getAllTeachers(String subjectName) async {
    final request = UniSystemRequest(type: UniSysApiRequestType.get, endpoint: 'subject/getAllTeachers/$subjectName');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    List<TeacherAssignation> list = [];
    for (var assignationJson in response) {
      list.add(TeacherAssignation.fromMap(assignationJson));
    }
    return list;
  }

  @override
  Future<Subject> getSubject(String name) async {
    final request = UniSystemRequest(type: UniSysApiRequestType.get, query: {"name": name}, endpoint: 'subject/getSubject');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Subject.fromMap(response);
  }

  @override
  Future<TeacherAssignation> modifyTeacherRole(int teacherId, String subjectName, String roleInClass) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeStudent(int studentId, String subjectName) {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.delete,
        query: {"studentId": studentId.toString(), "subjectName": subjectName},
        endpoint: 'subject/removeStudent');
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<void> removeTeacher(int teacherId, String subjectName) {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.delete,
        query: {"teacherId": teacherId.toString(), "subjectName": subjectName},
        endpoint: 'subject/removeTeacher');
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<Subject> updateSubject(SubjectDto subjectDto, String oldName) async {
    final request =
        UniSystemRequest(type: UniSysApiRequestType.patch, body: subjectDto.toMap(), endpoint: 'subject/updateSubject/$oldName');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Subject.fromMap(response);
  }
}
