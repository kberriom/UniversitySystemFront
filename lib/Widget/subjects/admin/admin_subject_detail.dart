import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_controller_extension/animation_controller_extension.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Controller/subject/admin_subject_detail_controller.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';
import 'package:university_system_front/Repository/users/student_repository.dart';
import 'package:university_system_front/Repository/users/teacher_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/common_components/carousel_widgets.dart';
import 'package:university_system_front/Widget/common_components/detail_page_widgets.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/subjects/admin/admin_user_for_subject_selectors.dart';

class AdminSubjectDetailWidget extends ConsumerStatefulWidget {
  final Subject subject;

  const AdminSubjectDetailWidget({super.key, required this.subject});

  @override
  ConsumerState<AdminSubjectDetailWidget> createState() => _SubjectDetailWidgetState();
}

class _SubjectDetailWidgetState extends ConsumerState<AdminSubjectDetailWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  bool deleteTeacherMode = false;
  bool deleteStudentMode = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBarAndroid(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.goEditPage(GoRouterRoutes.adminEditSubject, widget.subject);
            },
            child: const Icon(Icons.mode_edit)),
        body: UniSystemBackgroundDecoration(
          child: Column(
            children: [
              UniSystemDetailHeader(
                header: AnimatedComboTextTitle(
                  widthFactor: 0.9,
                  upText: context.localizations.subjectItemName,
                  downText: widget.subject.name,
                  downWidget: SubjectDetailLocationsIndicator(subject: widget.subject),
                  underlineWidget: SubjectDetailUnderlineInfo(subject: widget.subject),
                ),
              ),
              UniSystemDetailBody(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
                    child: ExpansionTile(
                      collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                      collapsedShape: const RoundedRectangleBorder(),
                      shape: const RoundedRectangleBorder(),
                      title: Text(context.localizations.detailSeeMoreInfo),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                              "${context.localizations.adminAddSubjectFormItemCreditsValue}: ${widget.subject.creditsValue}"),
                        ),
                        ListTile(
                          title: Text("${context.localizations.formItemDescription}: ${widget.subject.description}"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      QuickActionButton(
                        height: 40,
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
                        height: 40,
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  UniSystemDetailHeader(
                    alignment: Alignment.centerLeft,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    header: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Tooltip(
                            message: context.localizations.adminSubjectDetailQuickActRemoveTeacher,
                            child: const SubjectUserDeleteModeIconButton(UserRole.teacher),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.localizations.userTypeNameTeacher(2),
                            style: downTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  UserListCarousel<TeacherAssignation>(
                    future: ref.watch(subjectRepositoryProvider).getAllTeachers(widget.subject.name),
                    onTapCallBack: (data) async {
                      if (ref.read(userCarouselDeleteModeProvider.call(UserRole.teacher))) {
                        _deleteUserFromSubject(
                          ref.read(subjectRepositoryProvider).removeTeacher(data.id.teacherUserId, widget.subject.name),
                          UserRole.teacher,
                        );
                      } else {
                        context.goDetailPage(
                          GoRouterRoutes.adminTeacherDetail,
                          await ref.read(teacherRepositoryProvider).getUserTypeInfoById(data.id.teacherUserId),
                        );
                      }
                    },
                    noAssignedMsg: context.localizations.subjectNoTeacherAsgmt,
                    onDataWidgetCallback: (data) {
                      return SubjectCarouselUserItem(
                        userRole: UserRole.teacher,
                        image: const Image(
                          image: NetworkImage("https://placehold.co/300x300/png"), //todo FIX url
                          fit: BoxFit.cover,
                        ),
                        footer: [
                          FutureBuilder(
                            future: ref.watch(teacherRepositoryProvider).getUserTypeInfoById(data.id.teacherUserId),
                            builder: (context, snapshot) {
                              String name = "";
                              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                                name = ("${snapshot.data?.name} ${snapshot.data?.lastName}");
                              } else {
                                name = context.localizations.teacherItemName;
                              }
                              return Text(
                                name,
                                maxLines: 1,
                              );
                            },
                          ),
                          Text(
                            "${context.localizations.carouselUserItemTeacherRole}: ${data.roleInClass}",
                            maxLines: 1,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  UniSystemDetailHeader(
                    alignment: Alignment.centerLeft,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    header: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Tooltip(
                            message: context.localizations.adminSubjectDetailQuickActRemoveStudent,
                            child: const SubjectUserDeleteModeIconButton(UserRole.student),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.localizations.userTypeNameStudent(2),
                            style: downTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  UserListCarousel<StudentSubjectRegistration>(
                    future: ref.watch(subjectRepositoryProvider).getAllRegisteredStudents(widget.subject.name),
                    onTapCallBack: (data) async {
                      if (ref.read(userCarouselDeleteModeProvider.call(UserRole.student))) {
                        _deleteUserFromSubject(
                          ref.read(subjectRepositoryProvider).removeStudent(data.id.studentUserId, widget.subject.name),
                          UserRole.student,
                        );
                      } else {
                        data.subject = widget.subject;
                        context.goEditPage(GoRouterRoutes.adminSubjectStudentGrade, data);
                      }
                    },
                    noAssignedMsg: context.localizations.subjectNoStudentAsgmt,
                    onDataWidgetCallback: (data) {
                      return SubjectCarouselUserItem(
                        userRole: UserRole.student,
                        image: const Image(
                          image: NetworkImage("https://placehold.co/300x300/png"), //todo FIX url
                          fit: BoxFit.cover,
                        ),
                        footer: [
                          FutureBuilder(
                            future: ref.watch(studentRepositoryProvider).getUserTypeInfoById(data.id.studentUserId),
                            builder: (context, snapshot) {
                              String name = "";
                              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                                name = ("${snapshot.data?.name} ${snapshot.data?.lastName}");
                              } else {
                                name = context.localizations.studentItemName;
                              }
                              return Text(
                                name,
                                maxLines: 1,
                              );
                            },
                          ),
                          Text(
                            "${context.localizations.idTooltip}: ${data.id.studentUserId}",
                            maxLines: 1,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 88),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteUserFromSubject(Future deleteFuture, UserRole role) {
    showGeneralDialog(
      barrierLabel: "",
      barrierDismissible: false,
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackgroundWaitModal(
          future: deleteFuture,
        );
      },
    );
    deleteFuture.then((value) {
      if (mounted) {
        _scaffoldMessengerKey.showTextSnackBar(context.localizations.userDeletedFromSubject);
      }
      ref.invalidate(subjectRepositoryProvider);
    }, onError: (e) {
      if (mounted) {
        _scaffoldMessengerKey.showTextSnackBar(context.localizations.userDeleteGenericErrorFromSubject);
      }
    });
    deleteFuture.whenComplete(() => ref.read(userCarouselDeleteModeProvider.call(role).notifier).setMode(false));
  }
}

class SubjectUserDeleteModeIconButton extends ConsumerWidget {
  const SubjectUserDeleteModeIconButton(
    this.userRole, {
    super.key,
  });

  final UserRole userRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed: () => ref.read(userCarouselDeleteModeProvider.call(userRole).notifier).toggleMode(),
        icon: ref.watch(userCarouselDeleteModeProvider.call(userRole))
            ? const Icon(Icons.delete_forever)
            : const Icon(Icons.delete));
  }
}

class SubjectCarouselUserItem extends ConsumerStatefulWidget {
  const SubjectCarouselUserItem({
    super.key,
    required this.image,
    required this.footer,
    required this.userRole,
  });

  final Widget image;
  final List<Widget> footer;
  final UserRole userRole;

  @override
  ConsumerState<SubjectCarouselUserItem> createState() => _UserCarouselItemState();
}

class _UserCarouselItemState extends ConsumerState<SubjectCarouselUserItem> with AnimationMixin {
  final Tween<double> _shiverAnimationTween = Tween(begin: -0.005, end: 0.005);
  final Tween<double> _noAnimationTween = Tween(begin: 0, end: 0);
  late Tween<double> _currentTween;

  bool deleteMode = false;

  @override
  void initState() {
    _currentTween = _noAnimationTween;
    super.initState();
    ref.listenManual(
      fireImmediately: true,
      userCarouselDeleteModeProvider.call(widget.userRole),
      (previous, next) {
        setState(() {
          if (next) {
            controller.mirror(duration: Durations.short1);
            setState(() {
              _currentTween = _shiverAnimationTween;
              deleteMode = true;
            });
          } else {
            controller.stop(canceled: true);
            setState(() {
              _currentTween = _noAnimationTween;
              deleteMode = false;
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: controller.drive(_currentTween).value,
      duration: Durations.short1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  widget.image,
                  if (deleteMode)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Tooltip(
                        message: context.localizations.deleteModalAction,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kBorderRadiusBig, vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.footer,
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectDetailLocationsIndicator extends StatelessWidget {
  final Subject subject;

  const SubjectDetailLocationsIndicator({
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

class SubjectDetailUnderlineInfo extends StatelessWidget {
  final Subject subject;

  const SubjectDetailUnderlineInfo({
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
              Text("${context.localizations.dateStartTooltip}: ${subject.startDate}"),
            if (DateTime.tryParse(subject.startDate)!.isBefore(DateTime.now()))
              Text("${context.localizations.dateEndTooltip}: ${subject.endDate}"),
          ],
        ),
      ],
    );
  }
}
