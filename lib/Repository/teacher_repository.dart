import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Repository/user_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

part 'teacher_repository.g.dart';

@Riverpod(keepAlive: true)
TeacherRepository teacherRepository(TeacherRepositoryRef ref) {
  return TeacherRepository(ref);
}

class TeacherRepository implements UserRepository<Teacher, TeacherDto> {
  late final UniSystemApiService uniSystemApiService;

  TeacherRepository(Ref ref) {
    uniSystemApiService = UniSystemApiService(ref);
  }

  @override
  Future<void> deleteUserTypeInfo(BearerToken selfIdentityToken) {
    // TODO: implement deleteUserTypeInfo
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUserTypeInfoById(int id) {
    // TODO: implement deleteUserTypeInfoById
    throw UnimplementedError();
  }

  @override
  Future<List<Teacher>> getAllUserTypeInfo() async {
    const request = UniSystemRequest(type: UniSysApiRequestType.get, endpoint: 'teacher/getAllTeacherInfo');
    List<dynamic> response = await uniSystemApiService.makeRequest(request);
    List<Teacher> list = response.map((teacherJson) => Teacher.fromMap(teacherJson)).toList(growable: false);
    return list;
  }

  @override
  Future<PaginatedList<Teacher>> getAllUserTypeInfoPaged(int page, int size) async {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.get,
        query: {"page": page.toString(), "size": size.toString()},
        endpoint: 'teacher/getAllTeacherInfo/paged');
    List<dynamic> response = await uniSystemApiService.makeRequest(request);
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
  Future<Teacher> getUserTypeInfoById(int id) {
    // TODO: implement getUserTypeInfoById
    throw UnimplementedError();
  }

  @override
  Future<Teacher> updateUserTypeInfo(TeacherDto userDto) {
    // TODO: implement updateUserTypeInfo
    throw UnimplementedError();
  }

  @override
  Future<Teacher> updateUserTypeInfoById(int id) {
    // TODO: implement updateUserTypeInfoById
    throw UnimplementedError();
  }
}
