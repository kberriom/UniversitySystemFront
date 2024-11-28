import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Repository/grade/grade_repository.dart';

part 'grade_list_controller.g.dart';

@riverpod
class StudentRegistration extends _$StudentRegistration {
  @override
  Future<StudentSubjectRegistration> build(StudentSubjectRegistrationId registrationId) async {
    return ref
        .watch(gradeRepositoryProvider)
        .getStudentSubjectRegistration(registrationId.subjectId, registrationId.studentUserId);
  }

  Future<List<Grade>> getGradeList() {
    return Future.value(state.value!.subjectGrades!.toList(growable: false));
  }
}

@riverpod
class CurrentFinalGrade extends _$CurrentFinalGrade {
  @override
  Future<GradeDto?> build(StudentSubjectRegistration studentSubjectRegistration) {
    Future<List<Grade>> listFuture =
        ref.watch(studentRegistrationProvider.call(studentSubjectRegistration.id).notifier).getGradeList();

    return listFuture.then(
      (list) {
        if (list.isEmpty) {
          return null;
        }
        if (studentSubjectRegistration.finalGrade != null) {
          return GradeDto(
            gradeValue: studentSubjectRegistration.finalGrade,
            percentageOfFinalGrade: "100",
          );
        }

        double sum = 0;
        double currentPercentage = 0;

        for (Grade grade in list) {
          sum += double.parse(grade.gradeValue);
          currentPercentage += double.parse(grade.percentageOfFinalGrade);
        }

        return GradeDto(
          gradeValue: (sum / list.length).toStringAsFixed(2),
          percentageOfFinalGrade: currentPercentage.toStringAsFixed(2),
          description: null,
        );
      },
      onError: (e) {
        return null;
      },
    );
  }
}
