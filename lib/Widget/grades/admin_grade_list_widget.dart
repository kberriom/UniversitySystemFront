import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Controller/subject/grade/grade_list_controller.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Repository/grade/grade_repository.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/grades/grade_list_item_widget.dart';

class AdminGradeListWidget extends ConsumerStatefulWidget {
  final Future<List<Grade>> gradeListFuture;

  const AdminGradeListWidget({
    super.key,
    required this.gradeListFuture,
  });

  @override
  ConsumerState<AdminGradeListWidget> createState() => _GradeListWidgetState();
}

class _GradeListWidgetState extends ConsumerState<AdminGradeListWidget> with AnimationMixin {
  late final FixedExtentItemConstraints fixedExtentItemConstraints;

  @override
  void initState() {
    fixedExtentItemConstraints = FixedExtentItemConstraints(
      animationController: createController(unbounded: true, fps: 60),
      cardHeight: 80,
      cardMinWidthConstraints: 300,
      cardMaxWidthConstraints: 800,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureListBuilder(
      listFuture: widget.gradeListFuture,
      onDataWidgetBuilderCallback: (list) {
        return ListLayoutBuilder(
          list: list,
          itemConstraints: fixedExtentItemConstraints,
          itemWidget: (grade, itemConstraints) {
            return GradeListItem(
              key: ValueKey<Grade>(grade),
              data: grade,
              itemConstraints: itemConstraints,
              onDeleteCallback: () {
                final deleteFuture = ref
                    .read(gradeRepositoryProvider)
                    .removeStudentGrade(grade.registrationId.subjectId, grade.registrationId.studentUserId, grade.id);
                deleteFuture.then(
                  (_) {
                    if (context.mounted) {
                      ref.showTextSnackBar(context.localizations.deleteGradeSuccess);
                    }
                    ref.invalidate(studentRegistrationProvider);
                  },
                  onError: (e) {
                    if (context.mounted) {
                      ref.showTextSnackBar(context.localizations.deleteGradeError);
                    }
                  },
                );
              },
            );
          },
        );
      },
      loadingWidget: GenericSliverLoadingShimmer(fixedExtentItemConstraints: fixedExtentItemConstraints),
      errorWidget: GenericSliverWarning(errorMessage: context.localizations.verboseError),
      noDataWidget: GenericSliverWarning(errorMessage: context.localizations.noGradesRegistered),
    );
  }
}
