import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Repository/curriculum/curriculum_repository.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/detail_page_widgets.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/subjects/subject_for_result_widget.dart';

class AdminCurriculumDetail extends ConsumerStatefulWidget {
  final Curriculum curriculum;

  const AdminCurriculumDetail({super.key, required this.curriculum});

  @override
  ConsumerState<AdminCurriculumDetail> createState() => _AdminCurriculumDetailState();
}

class _AdminCurriculumDetailState extends ConsumerState<AdminCurriculumDetail> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBarAndroid(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.goEditPage(GoRouterRoutes.adminEditCurriculum, widget.curriculum);
            },
            child: const Icon(Icons.mode_edit)),
        body: UniSystemBackgroundDecoration(
          child: Column(
            children: [
              UniSystemDetailHeader(
                header: AnimatedComboTextTitle(
                  widthFactor: 0.9,
                  upText: context.localizations.curriculumsItemName,
                  downText: widget.curriculum.name,
                  underlineWidget: CurriculumUnderlineInfo(curriculum: widget.curriculum),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    ExpansionTile(
                      collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                      collapsedShape: const RoundedRectangleBorder(),
                      shape: const RoundedRectangleBorder(),
                      title: Text(context.localizations.detailSeeMoreInfo),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      children: <Widget>[
                        ListTile(title: Text("${context.localizations.formItemDescription}: ${widget.curriculum.description}")),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        QuickActionButton(
                            height: 40,
                            text: context.localizations.adminCurriculumDetailQuickActAddSubject,
                            onPressed: () {
                              showGeneralDialog(
                                transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
                                  opacity: animation.drive(CurveTween(curve: Curves.linearToEaseOut)),
                                  child: child,
                                ),
                                barrierDismissible: true,
                                barrierLabel: "",
                                context: context,
                                pageBuilder:
                                    (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                                  return ItemSelectionModal(
                                    title: context.localizations.curriculumDetailAddSubjectModalTitle,
                                    widthFactor: 0.95,
                                    child: UniSystemBackgroundDecoration.backgroundColor(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      child: SubjectForResultWidget(
                                        key: UniqueKey(),
                                        showSearchBar: true,
                                        excludeListCallback: () =>
                                            ref.read(curriculumRepositoryProvider).getAllSubjects(widget.curriculum.name),
                                        listCallback: () => ref.read(subjectRepositoryProvider).getAllSubjects(),
                                        onResultCallback: (subject) {
                                          final future = ref
                                              .read(curriculumRepositoryProvider)
                                              .addSubject(widget.curriculum.name, subject.name);
                                          showBackgroundWaitModal(context, future);
                                          future.then(
                                            (value) {
                                              if (context.mounted) {
                                                context.popFromDialog();
                                                _scaffoldMessengerKey.showTextSnackBar(
                                                    context.localizations.curriculumDetailAddSubjectModalSuccess);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => ref.invalidate(curriculumRepositoryProvider));
                            },
                            icon: const Icon(Icons.add)),
                        QuickActionButton(
                            height: 40,
                            text: context.localizations.adminCurriculumDetailQuickActRemoveSubject,
                            onPressed: () {
                              showGeneralDialog(
                                transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
                                  opacity: animation.drive(CurveTween(curve: Curves.linearToEaseOut)),
                                  child: child,
                                ),
                                barrierDismissible: true,
                                barrierLabel: "",
                                context: context,
                                pageBuilder:
                                    (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                                  return ItemSelectionModal(
                                    title: context.localizations.curriculumDetailRemoveSubjectModalTitle,
                                    widthFactor: 0.95,
                                    child: UniSystemBackgroundDecoration.backgroundColor(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      child: SubjectForResultWidget(
                                        showSearchBar: true,
                                        listCallback: () =>
                                            ref.read(curriculumRepositoryProvider).getAllSubjects(widget.curriculum.name),
                                        onResultCallback: (subject) {
                                          final future = ref
                                              .read(curriculumRepositoryProvider)
                                              .removeSubject(widget.curriculum.name, subject.name);
                                          showBackgroundWaitModal(context, future);
                                          future.then(
                                            (value) {
                                              if (context.mounted) {
                                                context.popFromDialog();
                                                _scaffoldMessengerKey.showTextSnackBar(
                                                    context.localizations.curriculumDetailRemoveSubjectModalSuccess);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => ref.invalidate(curriculumRepositoryProvider));
                            },
                            icon: const Icon(Icons.remove)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SubjectForResultWidget(
                  key: UniqueKey(),
                  listCallback: () => ref.watch(curriculumRepositoryProvider).getAllSubjects(widget.curriculum.name),
                  onResultCallback: (subject) => context.goDetailPage(GoRouterRoutes.adminSubjectDetail, subject),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurriculumUnderlineInfo extends StatelessWidget {
  final Curriculum curriculum;

  const CurriculumUnderlineInfo({
    super.key,
    required this.curriculum,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(message: context.localizations.idTooltip, child: const Icon(Icons.badge_outlined)),
            const SizedBox(width: 5),
            Text("${curriculum.id}")
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(message: context.localizations.dateStartTooltip, child: const Icon(Icons.calendar_month_outlined)),
            const SizedBox(width: 5),
            Text(curriculum.dateStart),
            const SizedBox(width: 5),
            Tooltip(message: context.localizations.dateEndTooltip, child: const Icon(Icons.calendar_month_outlined)),
            const SizedBox(width: 5),
            Text(curriculum.dateEnd),
          ],
        ),
      ],
    );
  }
}
