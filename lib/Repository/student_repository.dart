import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Repository/user_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

part 'student_repository.g.dart';

@Riverpod(keepAlive: true)
StudentRepository studentRepository(StudentRepositoryRef ref) {
  return StudentRepository(ref);
}

class StudentRepository implements UserRepository<Student, StudentDto> {
  late final UniSystemApiService uniSystemApiService;

  StudentRepository(Ref ref) {
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
  Future<List<Student>> getAllUserTypeInfo() async {
    const request = UniSystemRequest(type: UniSysApiRequestType.get, endpoint: 'student/getAllStudentInfo');
    List<dynamic> response = await uniSystemApiService.makeRequest(request);
    List<Student> list = response.map((studentJson) => Student.fromMap(studentJson)).toList(growable: false);
    return list;
  }

  @override
  Future<PaginatedList<Student>> getAllUserTypeInfoPaged(int page, int size) async {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.get,
        query: {"page": page.toString(), "size": size.toString()},
        endpoint: 'student/getAllStudentInfo/paged');
    List<dynamic> response = await uniSystemApiService.makeRequest(request);
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
  Future<Student> getUserTypeInfoById(int id) {
    // TODO: implement getUserTypeInfoById
    throw UnimplementedError();
  }

  @override
  Future<Student> updateUserTypeInfo(StudentDto userDto) {
    // TODO: implement updateUserTypeInfo
    throw UnimplementedError();
  }

  @override
  Future<Student> updateUserTypeInfoById(int id) {
    // TODO: implement updateUserTypeInfoById
    throw UnimplementedError();
  }
}
