import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/subject.dart';

abstract interface class CurriculumRepository {
  ///URL param [curriculumName], ignore response
  Future<void> addSubject(String curriculumName, String subjectName);

  Future<Curriculum> createCurriculum(CurriculumDTO curriculumDto);

  Future<Curriculum> updateCurriculum(String name, CurriculumDTO curriculumDto);

  Future<Curriculum> getCurriculum(String name);

  ///URL param [curriculumName]
  Future<List<Subject>> getAllSubjects(String curriculumName);

  Future<List<Curriculum>> getAllCurriculums();

  Future<PaginatedList<Curriculum>> getAllCurriculumsPaged(int page, int size);

  ///URL param [curriculumName]
  Future<void> removeSubject(String curriculumName, String subjectName);

  Future<void> deleteCurriculum(String name);
}
