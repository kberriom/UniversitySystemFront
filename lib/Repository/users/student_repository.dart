import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:university_system_front/Repository/users/user_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

part 'student_repository.g.dart';

@Riverpod(keepAlive: true)
StudentRepository studentRepository(Ref ref) {
  return StudentRepository(ref);
}

class StudentRepository implements UserRepository<Student, StudentUpdateDto> {
  late final UniSystemApiService _uniSystemApiService;

  StudentRepository(Ref ref) {
    _uniSystemApiService = UniSystemApiService(ref);
  }

  Future<Student> createStudent(StudentCreationDto dto) async {
    final request = UniSystemRequest(type: UniSysApiRestRequestType.post, body: dto.toMap(), endpoint: 'auth/createStudent');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Student.fromMap(response);
  }

  @override
  Future<void> deleteUserTypeInfo(BearerToken selfIdentityToken) {
    // TODO: implement deleteUserTypeInfo
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUserTypeInfoById(int id) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.delete,
      endpoint: 'student/deleteStudentInfo/$id',
    );
    return await _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<List<Student>> getAllUserTypeInfo() async {
    const request = UniSystemRequest(type: UniSysApiRestRequestType.get, endpoint: 'student/getAllStudentInfo');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    List<Student> list = response.map((studentJson) => Student.fromMap(studentJson)).toList(growable: false);
    return list;
  }

  @override
  Future<PaginatedList<Student>> getAllUserTypeInfoPaged(int page, int size) async {
    final request = UniSystemRequest(
        type: UniSysApiRestRequestType.get,
        query: {"page": page.toString(), "size": size.toString()},
        endpoint: 'student/getAllStudentInfo/paged');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    PageInfo pageInfo = PageInfo.fromMap(response[0]);
    response.removeAt(0);
    Set<Student> set = {};
    for (var studentJson in response) {
      set.add(Student.fromMap(studentJson));
    }
    return PaginatedList<Student>(pageInfo: pageInfo, set: set);
  }

  @override
  Future<Student> getUserTypeInfo(BearerToken selfIdentityToken) {
    // TODO: implement getUserTypeInfo
    throw UnimplementedError();
  }

  @override
  Future<Student> getUserTypeInfoById(int id) async {
    final request = UniSystemRequest(type: UniSysApiRestRequestType.get, endpoint: 'student/getStudentInfo/$id');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Student.fromMap(response);
  }

  @override
  Future<Student> updateUserTypeInfo(StudentUpdateDto updateDto) {
    // TODO: implement updateUserTypeInfo
    throw UnimplementedError();
  }

  @override
  Future<Student> updateUserTypeInfoById(int id, StudentUpdateDto updateDto) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.patch,
      body: updateDto.toMap(),
      endpoint: 'student/updateStudentInfo/$id',
    );
    Json response = await _uniSystemApiService.makeRequest(request);
    return Student.fromMap(response);
  }

  @override
  Future<void> adminUpdatePassword(AdminPasswordUpdateDto dto) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.post,
      endpoint: 'auth/adminUpdatePassword',
      body: {"email": dto.email, "newPassword": dto.newPassword},
    );
    return await _uniSystemApiService.makeRequest(request);
  }
}
