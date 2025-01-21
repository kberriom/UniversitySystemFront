import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:university_system_front/Repository/users/user_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

part 'teacher_repository.g.dart';

@Riverpod(keepAlive: true)
TeacherRepository teacherRepository(Ref ref) {
  return TeacherRepository(ref);
}

class TeacherRepository implements UserRepository<Teacher, TeacherUpdateDto> {
  late final UniSystemApiService _uniSystemApiService;

  TeacherRepository(Ref ref) {
    _uniSystemApiService = UniSystemApiService(ref);
  }

  Future<Teacher> createTeacher(TeacherCreationDto dto) async {
    final request = UniSystemRequest(type: UniSysApiRestRequestType.post, body: dto.toMap(), endpoint: 'auth/createTeacher');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Teacher.fromMap(response);
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
      endpoint: 'teacher/deleteTeacherInfo/$id',
    );
    return await _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<List<Teacher>> getAllUserTypeInfo() async {
    const request = UniSystemRequest(type: UniSysApiRestRequestType.get, endpoint: 'teacher/getAllTeacherInfo');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    List<Teacher> list = response.map((teacherJson) => Teacher.fromMap(teacherJson)).toList(growable: false);
    return list;
  }

  @override
  Future<PaginatedList<Teacher>> getAllUserTypeInfoPaged(int page, int size) async {
    final request = UniSystemRequest(
        type: UniSysApiRestRequestType.get,
        query: {"page": page.toString(), "size": size.toString()},
        endpoint: 'teacher/getAllTeacherInfo/paged');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    PageInfo pageInfo = PageInfo.fromMap(response[0]);
    response.removeAt(0);
    Set<Teacher> set = {};
    for (var teacherJson in response) {
      set.add(Teacher.fromMap(teacherJson));
    }
    return PaginatedList<Teacher>(pageInfo: pageInfo, set: set);
  }

  @override
  Future<Teacher> getUserTypeInfo(BearerToken selfIdentityToken) {
    // TODO: implement getUserTypeInfo
    throw UnimplementedError();
  }

  @override
  Future<Teacher> getUserTypeInfoById(int id) async {
    final request = UniSystemRequest(type: UniSysApiRestRequestType.get, endpoint: 'teacher/getTeacherInfo/$id');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Teacher.fromMap(response);
  }

  @override
  Future<Teacher> updateUserTypeInfo(TeacherUpdateDto updateDto) {
    // TODO: implement updateUserTypeInfo
    throw UnimplementedError();
  }

  @override
  Future<Teacher> updateUserTypeInfoById(int id, TeacherUpdateDto updateDto) async {
    final request = UniSystemRequest(
      type: UniSysApiRestRequestType.patch,
      body: updateDto.toMap(),
      endpoint: 'teacher/updateTeacherInfo/$id',
    );
    Json response = await _uniSystemApiService.makeRequest(request);
    return Teacher.fromMap(response);
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
