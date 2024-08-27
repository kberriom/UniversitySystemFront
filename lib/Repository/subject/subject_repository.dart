import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Repository/subject/subject_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

part 'subject_repository.g.dart';

@Riverpod(keepAlive: true)
SubjectRepositoryImpl subjectRepositoryImpl(SubjectRepositoryImplRef ref) {
  return SubjectRepositoryImpl(ref);
}

class SubjectRepositoryImpl implements SubjectRepository {
  late final UniSystemApiService uniSystemApiService;

  SubjectRepositoryImpl(Ref ref) {
    uniSystemApiService = UniSystemApiService(ref);
  }

  @override
  Future<StudentSubjectRegistration> addStudent(int studentId, int subjectName) {
    // TODO: implement addStudent
    throw UnimplementedError();
  }

  @override
  Future<TeacherAssignation> addTeacher(int teacherId, String subjectName, String roleInClass) {
    // TODO: implement addTeacher
    throw UnimplementedError();
  }

  @override
  Future<Subject> createSubject(SubjectDto subjectDto) {
    // TODO: implement createSubject
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSubject(String subjectName) {
    // TODO: implement deleteSubject
    throw UnimplementedError();
  }

  @override
  Future<List<StudentSubjectRegistration>> getAllRegisteredStudents() {
    // TODO: implement getAllRegisteredStudents
    throw UnimplementedError();
  }

  @override
  Future<List<Subject>> getAllSubjects() {
    // TODO: implement getAllSubject
    throw UnimplementedError();
  }

  @override
  Future<PaginatedList<Subject>> getAllSubjectsPaged(int page, int size) async {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.get,
        query: {"page": page.toString(), "size": size.toString()},
        endpoint: 'subject/getAllSubjects/paged');
    List<dynamic> response = await uniSystemApiService.makeRequest(request);
    PageInfo pageInfo = PageInfo.fromMap(response[0]);
    response.removeAt(0);
    Set<Subject> set = {};
    for (var subjectJson in response) {
      set.add(Subject.fromMap(subjectJson));
    }
    return PaginatedList<Subject>(pageInfo: pageInfo, set: set);
  }

  @override
  Future<List<TeacherAssignation>> getAllTeachers() {
    // TODO: implement getAllTeachers
    throw UnimplementedError();
  }

  @override
  Future<Subject> getSubject(String name) {
    // TODO: implement getSubject
    throw UnimplementedError();
  }

  @override
  Future<TeacherAssignation> modifyTeacherRole(int teacherId, String subjectName, String roleInClass) {
    // TODO: implement modifyTeacherRole
    throw UnimplementedError();
  }

  @override
  Future<void> removeStudent(int studentId, String subjectName) {
    // TODO: implement removeStudent
    throw UnimplementedError();
  }

  @override
  Future<void> removeTeacher(int teacherId, String subjectName) {
    // TODO: implement removeTeacher
    throw UnimplementedError();
  }

  @override
  Future<Subject> updateSubject(SubjectDto subjectDto) {
    // TODO: implement updateSubject
    throw UnimplementedError();
  }
}
