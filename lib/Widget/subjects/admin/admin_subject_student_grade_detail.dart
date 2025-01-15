import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Controller/subject/grade/grade_list_controller.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Repository/grade/grade_repository.dart';
import 'package:university_system_front/Repository/users/student_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/back_button_redirection.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/common_components/button_widgets.dart';
import 'package:university_system_front/Widget/common_components/detail_page_widgets.dart';
import 'package:university_system_front/Widget/common_components/dynamic_text_size.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/grades/grade_from_widget.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/grades/admin_grade_list_widget.dart';

class SubjectStudentGradeDetail extends ConsumerStatefulWidget {
  final StudentSubjectRegistration initialStudentSubjectRegistration;

  const SubjectStudentGradeDetail({
    super.key,
    required this.initialStudentSubjectRegistration,
  });

  @override
  ConsumerState<SubjectStudentGradeDetail> createState() => _SubjectStudentGradeDetailState();
}

class _SubjectStudentGradeDetailState extends ConsumerState<SubjectStudentGradeDetail> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final Subject subject;

  @override
  void initState() {
    subject = widget.initialStudentSubjectRegistration.subject!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SystemBackButtonRedirection(
      onRedirect: () => context.goDetailPage(GoRouterRoutes.adminSubjectDetail, subject),
      child: ref.watch(studentRegistrationProvider.call(widget.initialStudentSubjectRegistration.id)).when<Widget>(
        data: (studentSubjectRegistration) {
          return ScaffoldMessenger(
            key: _scaffoldMessengerKey,
            child: Scaffold(
              appBar: getAppBarAndroid(),
              floatingActionButton: AdminGradeFabButton(studentSubjectRegistration: studentSubjectRegistration),
              body: UniSystemBackgroundDecoration(
                child: Column(
                  children: [
                    GradeListDetailHeader(
                      studentSubjectRegistration: studentSubjectRegistration,
                      subject: subject,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding, vertical: 8),
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Row(
                        children: [
                          AnimatedRefreshButton(onPressed: () {
                            return ref.refresh(studentRegistrationProvider.call(studentSubjectRegistration.id).future);
                          }),
                          const SizedBox(width: 8),
                          Text(
                            context.localizations.gradeItemNamePlural,
                            style: downTextStyle.copyWith(fontSize: 24),
                          ),
                          Spacer(),
                          CurrentFinalGradeWidget(
                            studentSubjectRegistration: studentSubjectRegistration,
                            grade: ref.watch(currentFinalGradeProvider.call(studentSubjectRegistration)),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    FinalGradeActionButtons(
                      grade: ref.watch(currentFinalGradeProvider.call(studentSubjectRegistration)),
                      studentSubjectRegistration: studentSubjectRegistration,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref.refresh(studentRegistrationProvider.call(studentSubjectRegistration.id).future),
                        child: CustomScrollView(
                          slivers: [
                            AdminGradeListWidget(
                              gradeListFuture: ref
                                  .watch(studentRegistrationProvider.call(studentSubjectRegistration.id).notifier)
                                  .getGradeList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          return CustomScrollView(
            slivers: [
              GenericSliverWarning(
                  bottomWidget: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AnimatedRefreshButton(
                      onPressed: () =>
                          ref.refresh(studentRegistrationProvider.call(widget.initialStudentSubjectRegistration.id).future),
                    ),
                  ),
                  errorMessage: context.localizations.veryVerboseErrorTryAgain)
            ],
          );
        },
        loading: () {
          return const Center(child: SizedBox(height: 45, width: 45, child: CircularProgressIndicator()));
        },
      ),
    );
  }
}

class AdminGradeFabButton extends ConsumerWidget {
  const AdminGradeFabButton({
    super.key,
    required this.studentSubjectRegistration,
  });

  final StudentSubjectRegistration studentSubjectRegistration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: Durations.medium1,
      child: Builder(builder: (context) {
        if (studentSubjectRegistration.finalGrade == null) {
          return FutureBuilder(
            future: ref.watch(currentFinalGradeProvider.call(studentSubjectRegistration).future),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data!.percentageOfFinalGrade!.contains("100.")) {
                return const SizedBox();
              } else {
                return FloatingActionButton.extended(
                  key: UniqueKey(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddNewGradeModal(studentSubjectRegistration: studentSubjectRegistration);
                      },
                    );
                  },
                  label: Text(context.localizations.addGrade),
                  icon: BigIconWithCompanion(
                    mainIcon: Icons.featured_play_list_rounded,
                    companionIcon: Icons.add,
                    bigIconSize: Size(26, 23),
                    mainIconSize: 24,
                    companionIconSize: 16,
                    mainIconColor: Theme.of(context).colorScheme.primary,
                    companionIconColor: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                );
              }
            },
          );
        } else {
          return FloatingActionButton.extended(
            key: UniqueKey(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return ItemSelectionModal(
                    title: context.localizations.editFinalGrade,
                    child: Container(
                      alignment: Alignment.center,
                      child: FinalGradeActionButtons(
                        isFinalGradeOptionsMode: true,
                        onSuccessCallback: () {
                          context.popFromDialog();
                          context.popFromDialog();
                        },
                        height: 90,
                        grade: ref.read(currentFinalGradeProvider.call(studentSubjectRegistration)),
                        studentSubjectRegistration: studentSubjectRegistration,
                      ),
                    ),
                  );
                },
              );
            },
            label: Text(context.localizations.editFinalGrade),
            icon: BigIconWithCompanion(
              mainIcon: Icons.featured_play_list_rounded,
              companionIcon: Icons.warning_rounded,
              bigIconSize: Size(26, 23),
              mainIconSize: 24,
              companionIconSize: 16,
              mainIconColor: Theme.of(context).colorScheme.primary,
              companionIconColor: Colors.redAccent,
            ),
          );
        }
      }),
    );
  }
}

class GradeListDetailHeader extends ConsumerWidget {
  const GradeListDetailHeader({
    super.key,
    required this.studentSubjectRegistration,
    required this.subject,
  });

  final StudentSubjectRegistration studentSubjectRegistration;
  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UniSystemDetailHeader(
      header: AnimatedComboTextTitle(
        widthFactor: 0.9,
        upWidget: Flexible(
          child: AnimatedSwitcher(
            duration: Durations.medium1,
            child: FutureBuilder(
              future: ref.watch(studentRepositoryProvider).getUserTypeInfoById(studentSubjectRegistration.id.studentUserId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DynamicTextSize(
                    child: Text(
                      context.localizations.studentNameSubjectProgress(snapshot.data!.name),
                      style: upTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                } else {
                  return Text(
                    context.localizations.studentSubjectProgress,
                    style: upTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }
              },
            ),
          ),
        ),
        downWidget: Flexible(
          child: Row(
            children: [
              Icon(Icons.book_outlined),
              SizedBox(width: 3),
              Flexible(
                child: DynamicTextSize(
                  minSize: 12,
                  child: Text(
                    subject.name,
                    style: downTextStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddNewGradeModal extends ConsumerWidget {
  const AddNewGradeModal({
    super.key,
    required this.studentSubjectRegistration,
    this.isFinalGrade = false,
    void Function()? onSuccessCallback,
  }) : _onSuccessCallback = onSuccessCallback;

  final StudentSubjectRegistration studentSubjectRegistration;
  final bool isFinalGrade;
  final VoidCallback? _onSuccessCallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ItemSelectionModal(
      title: isFinalGrade ? context.localizations.setFinalGrade : context.localizations.addNewGrade,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: kBodyHorizontalConstraints,
          child: GradeFormWidget(
            editOnlyGradeValue: isFinalGrade,
            existingGrade: isFinalGrade
                ? GradeDto(description: context.localizations.finalGrade, gradeValue: null, percentageOfFinalGrade: "100")
                : null,
            existingRegistration: studentSubjectRegistration,
            onSubmitCallback: (formGrade) {
              Future future;
              if (isFinalGrade) {
                future = ref.read(gradeRepositoryProvider).setStudentFinalGrade(
                    studentSubjectRegistration.id.subjectId, studentSubjectRegistration.id.studentUserId, formGrade.gradeValue!);
              } else {
                future = ref.read(gradeRepositoryProvider).addStudentGrade(
                    studentSubjectRegistration.id.subjectId, studentSubjectRegistration.id.studentUserId, formGrade);
              }
              showGeneralDialog(
                barrierLabel: "",
                barrierDismissible: false,
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return BackgroundWaitModal(
                    future: future,
                  );
                },
              );
              future.then((value) {
                if (context.mounted) {
                  ref.invalidate(gradeRepositoryProvider);
                  ref.showTextSnackBar(context.localizations.addGradeSuccess);

                  if (_onSuccessCallback != null) {
                    _onSuccessCallback();
                  } else {
                    context.popFromDialog();
                  }
                }
              }, onError: (e) {
                if (context.mounted) {
                  switch ((e as Exception).toString()) {
                    case String error when error.contains("400") && error.contains("gradeValue"):
                      ref.showTextSnackBar(context.localizations.gradeValidationValueConstraints);
                    case String error when error.contains("400") && error.contains("excede 100%"):
                      ref.showTextSnackBar(context.localizations.gradeValidationPercentageConstraints);
                    case String error when error.contains("400"):
                      ref.showTextSnackBar(context.localizations.invalidGrade);
                    case _:
                      ref.showTextSnackBar(context.localizations.verboseErrorTryAgain);
                  }
                  context.popFromDialog();
                }
              });
            },
            buttonContent: Text(isFinalGrade ? context.localizations.setGrade : context.localizations.addGrade),
          ),
        ),
      ),
    );
  }
}

class FinalGradeActionButtons extends ConsumerWidget {
  final AsyncValue<GradeDto?> grade;
  final StudentSubjectRegistration studentSubjectRegistration;
  final VoidCallback? _onSuccessCallback;
  final bool isFinalGradeOptionsMode;
  final double height;

  const FinalGradeActionButtons({
    super.key,
    required this.grade,
    required this.studentSubjectRegistration,
    this.isFinalGradeOptionsMode = false,
    this.height = 40,
    void Function()? onSuccessCallback,
  }) : _onSuccessCallback = onSuccessCallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: Durations.medium1,
      child: grade.whenOrNull(
        data: (data) {
          if (data != null && data.percentageOfFinalGrade!.contains("100.") && studentSubjectRegistration.finalGrade == null ||
              isFinalGradeOptionsMode) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  QuickActionButton(
                    height: height,
                    text: context.localizations.autoFinalGrade,
                    onPressed: () {
                      final future = ref.read(gradeRepositoryProvider).setStudentFinalGradeAuto(
                          studentSubjectRegistration.id.subjectId, studentSubjectRegistration.id.studentUserId);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return BackgroundWaitModal(future: future);
                        },
                      );
                      future.then((value) {
                        ref.invalidate(gradeRepositoryProvider);
                        if (context.mounted) {
                          if (isFinalGradeOptionsMode) {
                            context.popFromDialog();
                          }
                          ref.showTextSnackBar(context.localizations.autoGradeSuccess);
                        }
                      }, onError: (e) {
                        if (context.mounted) {
                          ref.showTextSnackBar(context.localizations.verboseErrorTryAgain);
                        }
                      });
                    },
                    icon: BigIconWithCompanion(
                      mainIcon: Icons.featured_play_list_rounded,
                      companionIcon: Icons.auto_awesome,
                      bigIconSize: Size(40, 24),
                      mainIconSize: 24,
                      companionIconSize: 16,
                      mainIconColor: Theme.of(context).colorScheme.primary,
                      companionIconColor: Colors.amberAccent,
                    ),
                  ),
                  QuickActionButton(
                    height: height,
                    text: context.localizations.setFinalGrade,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AddNewGradeModal(
                            onSuccessCallback: _onSuccessCallback,
                            studentSubjectRegistration: studentSubjectRegistration,
                            isFinalGrade: true,
                          );
                        },
                      );
                    },
                    icon: BigIconWithCompanion(
                      mainIcon: Icons.featured_play_list_rounded,
                      companionIcon: Icons.check,
                      bigIconSize: Size(26, 24),
                      mainIconSize: 24,
                      companionIconSize: 16,
                      mainIconColor: Theme.of(context).colorScheme.primary,
                      companionIconColor: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                  if (studentSubjectRegistration.finalGrade != null)
                    QuickActionButton(
                      height: height,
                      text: context.localizations.deleteFinalGrade,
                      onPressed: () {
                        final future = ref.read(gradeRepositoryProvider).deleteStudentFinalGrade(
                            studentSubjectRegistration.id.subjectId, studentSubjectRegistration.id.studentUserId);
                        showDialog(
                          context: context,
                          builder: (context) {
                            return BackgroundWaitModal(future: future);
                          },
                        );
                        future.then((value) {
                          ref.invalidate(gradeRepositoryProvider);
                          if (context.mounted) {
                            context.popFromDialog();
                            ref.showTextSnackBar(context.localizations.deleteFinalGradeSuccess);
                          }
                        }, onError: (e) {
                          if (context.mounted) {
                            ref.showTextSnackBar(context.localizations.verboseErrorTryAgain);
                          }
                        });
                      },
                      icon: BigIconWithCompanion(
                        mainIcon: Icons.featured_play_list_rounded,
                        companionIcon: Icons.highlight_remove_rounded,
                        bigIconSize: Size(25, 24),
                        mainIconSize: 24,
                        companionIconSize: 16,
                        mainIconColor: Theme.of(context).colorScheme.primary,
                        companionIconColor: Colors.red,
                      ),
                    ),
                ],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class CurrentFinalGradeWidget extends StatelessWidget {
  final AsyncValue<GradeDto?> grade;
  final StudentSubjectRegistration studentSubjectRegistration;

  const CurrentFinalGradeWidget({
    super.key,
    required this.grade,
    required this.studentSubjectRegistration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Durations.medium1,
      child: grade.whenOrNull<Widget?>(
        data: (grade) {
          if (grade != null && grade.gradeValue != null) {
            return Tooltip(
              message: studentSubjectRegistration.finalGrade == null
                  ? context.localizations.approxFinalGrade
                  : context.localizations.finalGrade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${studentSubjectRegistration.finalGrade == null ? "~" : ""}${grade.gradeValue!}${studentSubjectRegistration.finalGrade == null ? " " : ""}",
                    style: downTextStyle,
                  ),
                  Text(
                    "${grade.percentageOfFinalGrade!}%",
                    style: upTextStyle,
                  ),
                ],
              ),
            );
          } else {
            return null;
          }
        },
      ),
    );
  }
}
