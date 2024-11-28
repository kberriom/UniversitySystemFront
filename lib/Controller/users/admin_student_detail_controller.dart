import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';

part 'admin_student_detail_controller.g.dart';

@riverpod
class SubjectListByStudentId extends _$SubjectListByStudentId {
  @override
  Future<List<Subject>> build(int studentId) {
    return ref.watch(subjectRepositoryProvider).getAllSubjectsByStudentId(studentId);
  }
}
