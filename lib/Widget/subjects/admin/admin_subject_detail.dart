import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/animated_text_title.dart';
import 'package:university_system_front/Widget/common_components/detail_page_widgets.dart';
import 'package:university_system_front/Widget/common_components/form_widgets.dart';
import 'package:university_system_front/Widget/common_components/modals.dart';
import 'package:university_system_front/Widget/common_components/scaffold_background_decoration.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/users/admin/admin_users_widget.dart';

class AdminSubjectDetailWidget extends ConsumerStatefulWidget {
  final Subject subject;

  const AdminSubjectDetailWidget({super.key, required this.subject});

  @override
  ConsumerState<AdminSubjectDetailWidget> createState() => _SubjectDetailWidgetState();
}

class _SubjectDetailWidgetState extends ConsumerState<AdminSubjectDetailWidget> {
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
              GoRouter.of(context).pushReplacement(
                  '${GoRouterRoutes.adminSubjects.routeName}/${GoRouterRoutes.adminSubjectDetail.routeName}/${GoRouterRoutes.adminEditSubject.routeName}',
                  extra: widget.subject);
            },
            child: const Icon(Icons.mode_edit)),
        body: ScaffoldBackgroundDecoration(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000, minWidth: 300),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AnimatedComboTextTitle(
                          widthFactor: 0.9,
                          upText: context.localizations.subjectItemName,
                          downText: widget.subject.name,
                          downWidget: SubjectLocationsIndicator(subject: widget.subject),
                          underlineWidget: SubjectUnderlineInfo(subject: widget.subject),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
                    width: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ExpansionTile(
                          collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          collapsedShape: const RoundedRectangleBorder(),
                          shape: const RoundedRectangleBorder(),
                          title: Text(context.localizations.subjectDetailSeeMoreInfo),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          children: <Widget>[
                            ListTile(
                                title: Text(
                                    "${context.localizations.adminAddSubjectFormItemCreditsValue}: ${widget.subject.creditsValue}")),
                            ListTile(
                                title: Text(
                                    "${context.localizations.adminAddSubjectFormItemDescription}: ${widget.subject.description}")),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            QuickActionButton(
                              text: context.localizations.adminSubjectDetailQuickActAddTeacher,
                              icon: const Icon(Icons.add),
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
                                    return SelectTeacherForSubjectWidget(subject: widget.subject);
                                  },
                                );
                              },
                            ),
                            QuickActionButton(
                              text: context.localizations.adminSubjectDetailQuickActRemoveTeacher,
                              icon: const Icon(Icons.remove),
                              onPressed: () {}, //todo add action
                            ),
                            QuickActionButton(
                              text: context.localizations.adminSubjectDetailQuickActAddStudent,
                              icon: const Icon(Icons.add),
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
                                    return SelectStudentForSubjectWidget(subject: widget.subject);
                                  },
                                );
                              },
                            ),
                            QuickActionButton(
                              text: context.localizations.adminSubjectDetailQuickActRemoveStudent,
                              icon: const Icon(Icons.remove),
                              onPressed: () {}, //todo add action
                            ),
                          ],
                        ),
                        AnimatedTextTitle(text: context.localizations.userTypeNameTeacher(2)),
                        UserListCarousel<TeacherAssignation>(
                          future: ref.watch(subjectRepositoryProvider).getAllTeachers(widget.subject.name),
                          noAssignedMsg: context.localizations.subjectNoTeacherAsgmt,
                          onDataWidgetCallback: (data) {
                            return UserCarouselItem(
                              image: const Image(
                                image: NetworkImage("https://placehold.co/300x300/png"), //todo FIX url
                                fit: BoxFit.cover,
                              ),
                              footer: [
                                Text(
                                  "${context.localizations.idTooltip}: ${data.id.teacherUserId}",
                                  maxLines: 1,
                                ),
                                Text(
                                  "Role: ${data.roleInClass}",
                                  maxLines: 1,
                                ),
                              ],
                            );
                          },
                        ),
                        AnimatedTextTitle(text: context.localizations.userTypeNameStudent(2)),
                        UserListCarousel<StudentSubjectRegistration>(
                          future: ref.watch(subjectRepositoryProvider).getAllRegisteredStudents(widget.subject.name),
                          noAssignedMsg: context.localizations.subjectNoStudentAsgmt,
                          onDataWidgetCallback: (data) {
                            return UserCarouselItem(
                              image: const Image(
                                image: NetworkImage("https://placehold.co/300x300/png"), //todo FIX url
                                fit: BoxFit.cover,
                              ),
                              footer: [
                                Text(
                                  "${context.localizations.idTooltip}: ${data.id.studentUserId}",
                                  maxLines: 1,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
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

class SelectStudentForSubjectWidget extends ConsumerWidget {
  final Subject subject;

  const SelectStudentForSubjectWidget({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DialogModal(
      canPop: true,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.9,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), icon: const Icon(Icons.close)),
                Flexible(
                  child: AnimatedTextTitle(
                    text: context.localizations.selectStudentForResult,
                    widthFactor: 0.9,
                    fontSize: 27,
                  ),
                ),
              ],
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadiusBig),
                child: AdminUsersWidget(
                    filterByTeacher: false,
                    forResultCallback: (user, role) {
                      final future = ref.read(subjectRepositoryProvider).addStudent(user.id, subject.name);
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
                          ref.invalidate(subjectRepositoryProvider);
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      }, onError: (e) {
                        if (context.mounted) {
                          if (e is Exception && e.toString().contains("409")) {
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(SnackBar(content: Text(context.localizations.userAlreadyInSubjectError)));
                          } else {
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(SnackBar(content: Text(context.localizations.verboseErrorTryAgain)));
                          }
                        }
                      });
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectTeacherForSubjectWidget extends ConsumerStatefulWidget {
  final Subject subject;

  const SelectTeacherForSubjectWidget({
    super.key,
    required this.subject,
  });

  @override
  ConsumerState<SelectTeacherForSubjectWidget> createState() => _SelectTeacherForSubjectWidgetState();
}

class _SelectTeacherForSubjectWidgetState extends ConsumerState<SelectTeacherForSubjectWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _teacherRoleController;

  @override
  void initState() {
    _teacherRoleController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _teacherRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogModal(
      canPop: true,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.9,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), icon: const Icon(Icons.close)),
                Flexible(
                  child: AnimatedTextTitle(
                    text: context.localizations.selectTeacherForResult,
                    widthFactor: 0.9,
                    fontSize: 27,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _teacherRoleController,
                  validator: FormBuilderValidators.required(),
                  decoration: buildUniSysInputDecoration(
                      context.localizations.teacherRole, Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadiusBig),
                child: AdminUsersWidget(
                  filterByStudent: false,
                  forResultCallback: (user, role) {
                    if (_formKey.currentState?.validate() ?? false) {
                      final future = ref
                          .read(subjectRepositoryProvider)
                          .addTeacher(user.id, widget.subject.name, _teacherRoleController.value.text);
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
                          ref.invalidate(subjectRepositoryProvider);
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      }, onError: (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(SnackBar(content: Text(context.localizations.verboseErrorTryAgain)));
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectLocationsIndicator extends StatelessWidget {
  final Subject subject;

  const SubjectLocationsIndicator({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        if (subject.remote) Tooltip(message: context.localizations.subjectItemIsRemote, child: const Icon(Icons.laptop)),
        if (subject.onSite) Tooltip(message: context.localizations.subjectItemIsOnSite, child: const Icon(Icons.home_work)),
      ],
    );
  }
}

class SubjectUnderlineInfo extends StatelessWidget {
  final Subject subject;

  const SubjectUnderlineInfo({
    super.key,
    required this.subject,
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
            Text("${subject.id}")
          ],
        ),
        if ((subject.roomLocation ?? "").isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(message: context.localizations.adminAddSubjectFormItemRoomLoc, child: const Icon(Icons.location_on_sharp)),
              const SizedBox(width: 5),
              Text(subject.roomLocation ?? "")
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(message: context.localizations.dateTooltip, child: const Icon(Icons.calendar_month_outlined)),
            const SizedBox(width: 5),
            if (DateTime.tryParse(subject.startDate)!.isAfter(DateTime.now()))
              Text("${context.localizations.dateStartTooltip} ${subject.startDate}"),
            if (DateTime.tryParse(subject.startDate)!.isBefore(DateTime.now()))
              Text("${context.localizations.dateEndTooltip} ${subject.endDate}"),
          ],
        ),
      ],
    );
  }
}
