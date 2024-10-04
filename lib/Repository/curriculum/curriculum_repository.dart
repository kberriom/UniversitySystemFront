import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Repository/curriculum/curriculum_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

part 'curriculum_repository.g.dart';

@Riverpod(keepAlive: true)
CurriculumRepository curriculumRepository(CurriculumRepositoryRef ref) {
  return _CurriculumRepositoryImpl(ref);
}

class _CurriculumRepositoryImpl implements CurriculumRepository {
  late final UniSystemApiService _uniSystemApiService;

  _CurriculumRepositoryImpl(Ref ref) {
    _uniSystemApiService = UniSystemApiService(ref);
  }

  @override
  Future<void> addSubject(String curriculumName, String subjectName) {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.put, query: {"subjectName": subjectName}, endpoint: 'curriculum/addSubject/$curriculumName');
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<Curriculum> createCurriculum(CurriculumDTO curriculumDto) {
    // TODO: implement createCurriculum
    throw UnimplementedError();
  }

  @override
  Future<List<Curriculum>> getAllCurriculums() {
    // TODO: implement getAllCurriculums
    throw UnimplementedError();
  }

  @override
  Future<PaginatedList<Curriculum>> getAllCurriculumsPaged(int page, int size) async {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.get,
        query: {"page": page.toString(), "size": size.toString()},
        endpoint: 'curriculum/getAllCurriculums/paged');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    PageInfo pageInfo = PageInfo.fromMap(response[0]);
    response.removeAt(0);
    Set<Curriculum> set = {};
    for (var curriculumJson in response) {
      set.add(Curriculum.fromMap(curriculumJson));
    }
    return PaginatedList<Curriculum>(pageInfo: pageInfo, set: set);
  }

  @override
  Future<List<Subject>> getAllSubjects(String curriculumName) async {
    final request = UniSystemRequest(type: UniSysApiRequestType.get, endpoint: 'curriculum/getAllSubjects/$curriculumName');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    List<Subject> list = [];
    for (var subjectJson in response) {
      list.add(Subject.fromMap(subjectJson));
    }
    return list;
  }

  @override
  Future<Curriculum> getCurriculum(String name) {
    // TODO: implement getCurriculum
    throw UnimplementedError();
  }

  @override
  Future<void> removeCurriculum(String name) {
    // TODO: implement removeCurriculum
    throw UnimplementedError();
  }

  @override
  Future<void> removeSubject(String curriculumName, String subjectName) {
    final request = UniSystemRequest(
        type: UniSysApiRequestType.delete,
        query: {"subjectName": subjectName},
        endpoint: 'curriculum/removeSubject/$curriculumName');
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<Curriculum> updateCurriculum(String name, CurriculumDTO curriculumDto) {
    // TODO: implement updateCurriculum
    throw UnimplementedError();
  }
}
