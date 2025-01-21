import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Repository/curriculum/curriculum_repository_interface.dart';
import 'package:university_system_front/Service/uni_system_client/request_mode_provider.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

part 'curriculum_repository.g.dart';

@Riverpod(keepAlive: true)
CurriculumRepository curriculumRepository(Ref ref) {
  switch (ref.watch(requestModeProvider)) {
    case UniSysApiRequestMethod.rest:
      return _CurriculumRepositoryImpl(ref);
    case UniSysApiRequestMethod.graphQl:
      return _GraphQlCurriculumRepositoryImpl(ref);
  }
}

class _GraphQlCurriculumRepositoryImpl implements CurriculumRepository {
  late final UniSystemApiService _uniSystemApiService;

  _GraphQlCurriculumRepositoryImpl(Ref ref) {
    _uniSystemApiService = UniSystemApiService(ref);
  }

  @override
  Future<void> addSubject(String curriculumName, String subjectName) {
    final request = UniSystemRequest.graphQl(
      requestType: UniSysApiGraphQlRequestType.mutation,
      operationName: "addSubjectToCurriculum",
      operation: 'addSubjectToCurriculum(curriculumName: "$curriculumName", subjectName: "$subjectName"){...on Subject{id}}',
    );
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<Curriculum> createCurriculum(CurriculumDTO curriculumDto) async {
    final request = UniSystemRequest.graphQl(
      requestType: UniSysApiGraphQlRequestType.mutation,
      operationName: "createCurriculum",
      operation: """
      createCurriculum(
    curriculumDto: {name: "${curriculumDto.name}", description: "${curriculumDto.description}", dateStart: "${curriculumDto.dateStart}", dateEnd: "${curriculumDto.dateEnd}"}
  ) {
    id,name,description,dateStart,dateEnd
  }
    """,
    );
    Json response = (await _uniSystemApiService.makeRequest(request))["data"]["createCurriculum"];
    return Curriculum.fromMap(response);
  }

  @override
  Future<List<Curriculum>> getAllCurriculums() {
    // TODO: implement getAllCurriculums
    throw UnimplementedError();
  }

  @override
  Future<PaginatedList<Curriculum>> getAllCurriculumsPaged(int page, int size) async {
    final request =
        UniSystemRequest.graphQl(operationName: "curriculumsPaged", requestType: UniSysApiGraphQlRequestType.query, operation: """
    curriculumsPaged(page: $page, size: $size) {
      ... on PageInfoDto {
        currentPage,currentPageSize,maxPages,maxItems
      },
      ... on Curriculum {
        id,name,description,dateStart,dateEnd
      }
    }""");

    List<dynamic> response = (await _uniSystemApiService.makeRequest(request))['data']['curriculumsPaged'];

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
    final request = UniSystemRequest.graphQl(
        requestType: UniSysApiGraphQlRequestType.query, operationName: "subjectsInCurriculum", operation: """
        subjectsInCurriculum(curriculumName: "$curriculumName") {
    id,name,description,startDate,endDate,remote,onSite,roomLocation,creditsValue
  }
    """);
    List<dynamic> response = (await _uniSystemApiService.makeRequest(request))["data"]["subjectsInCurriculum"];
    List<Subject> list = [];
    for (var subjectJson in response) {
      list.add(Subject.fromMap(subjectJson));
    }
    return list;
  }

  @override
  Future<Curriculum> getCurriculum(String name) async {
    final request = UniSystemRequest.graphQl(
      requestType: UniSysApiGraphQlRequestType.query,
      operationName: "curriculum",
      operation: 'curriculum(name: "$name"){id}',
    );
    Json response = (await _uniSystemApiService.makeRequest(request))["data"]["curriculum"];
    return Curriculum.fromMap(response);
  }

  @override
  Future<void> deleteCurriculum(String name) {
    final request = UniSystemRequest.graphQl(
      requestType: UniSysApiGraphQlRequestType.mutation,
      operationName: "deleteCurriculum",
      operation: 'deleteCurriculum(name: "$name")',
    );
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<void> removeSubject(String curriculumName, String subjectName) {
    final request = UniSystemRequest.graphQl(
      requestType: UniSysApiGraphQlRequestType.mutation,
      operationName: "removeSubjectFromCurriculum",
      operation: 'removeSubjectFromCurriculum(curriculumName: "$curriculumName", subjectName: "$subjectName")',
    );
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<Curriculum> updateCurriculum(String name, CurriculumDTO curriculumDto) async {
    final request = UniSystemRequest.graphQl(
        requestType: UniSysApiGraphQlRequestType.mutation, operationName: "updateCurriculum", operation: """
        updateCurriculum(name: "$name", curriculumDto: {
        name: "${curriculumDto.name}",
        description: "${curriculumDto.description}",
        dateStart: "${curriculumDto.dateStart}",
        dateEnd: "${curriculumDto.dateEnd}"}
  ) {
    id,name,description,dateStart,dateEnd
  }
    """);
    Json response = (await _uniSystemApiService.makeRequest(request))["data"]["updateCurriculum"];
    return Curriculum.fromMap(response);
  }
}

class _CurriculumRepositoryImpl implements CurriculumRepository {
  late final UniSystemApiService _uniSystemApiService;

  _CurriculumRepositoryImpl(Ref ref) {
    _uniSystemApiService = UniSystemApiService(ref);
  }

  @override
  Future<void> addSubject(String curriculumName, String subjectName) {
    final request = UniSystemRequest(
        type: UniSysApiRestRequestType.put,
        query: {"subjectName": subjectName},
        endpoint: 'curriculum/addSubject/$curriculumName');
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<Curriculum> createCurriculum(CurriculumDTO curriculumDto) async {
    final request = UniSystemRequest(
        type: UniSysApiRestRequestType.post, endpoint: 'curriculum/createCurriculum', body: curriculumDto.toMap());
    Json response = await _uniSystemApiService.makeRequest(request);
    return Curriculum.fromMap(response);
  }

  @override
  Future<List<Curriculum>> getAllCurriculums() {
    // TODO: implement getAllCurriculums
    throw UnimplementedError();
  }

  @override
  Future<PaginatedList<Curriculum>> getAllCurriculumsPaged(int page, int size) async {
    final request = UniSystemRequest(
        type: UniSysApiRestRequestType.get,
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
    final request = UniSystemRequest(type: UniSysApiRestRequestType.get, endpoint: 'curriculum/getAllSubjects/$curriculumName');
    List<dynamic> response = await _uniSystemApiService.makeRequest(request);
    List<Subject> list = [];
    for (var subjectJson in response) {
      list.add(Subject.fromMap(subjectJson));
    }
    return list;
  }

  @override
  Future<Curriculum> getCurriculum(String name) async {
    final request =
        UniSystemRequest(type: UniSysApiRestRequestType.get, query: {"name": name}, endpoint: 'curriculum/getCurriculum');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Curriculum.fromMap(response);
  }

  @override
  Future<void> deleteCurriculum(String name) {
    final request =
        UniSystemRequest(type: UniSysApiRestRequestType.delete, query: {"name": name}, endpoint: 'curriculum/deleteCurriculum');
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<void> removeSubject(String curriculumName, String subjectName) {
    final request = UniSystemRequest(
        type: UniSysApiRestRequestType.delete,
        query: {"subjectName": subjectName},
        endpoint: 'curriculum/removeSubject/$curriculumName');
    return _uniSystemApiService.makeRequest(request);
  }

  @override
  Future<Curriculum> updateCurriculum(String name, CurriculumDTO curriculumDto) async {
    final request = UniSystemRequest(
        type: UniSysApiRestRequestType.patch, body: curriculumDto.toMap(), endpoint: 'curriculum/updateCurriculum/$name');
    Json response = await _uniSystemApiService.makeRequest(request);
    return Curriculum.fromMap(response);
  }
}
