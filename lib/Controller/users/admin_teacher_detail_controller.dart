import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';

part 'admin_teacher_detail_controller.g.dart';

@riverpod
class TeacherSubjectsByTeacherId extends _$TeacherSubjectsByTeacherId {
  @override
  Future<List<Subject>> build(int teacherId) {
    return ref.watch(subjectRepositoryProvider).getAllSubjectsByTeacherId(teacherId);
  }
}
