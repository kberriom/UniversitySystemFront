import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Controller/users/admin_users_widget_controller.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Repository/users/student_repository.dart';
import 'package:university_system_front/Repository/users/teacher_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Router/route_extra/admin_add_user_widget_extra.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/common_components/button_widgets.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/users/student_form_widget.dart';
import 'package:university_system_front/Widget/users/teacher_form_widget.dart';

class AdminAddUser extends ConsumerStatefulWidget {
  final AdminAddUserWidgetExtra extra;

  const AdminAddUser({
    super.key,
    required this.extra,
  });

  @override
  ConsumerState<AdminAddUser> createState() => _AdminAddUserState();
}

class _AdminAddUserState extends ConsumerState<AdminAddUser> {
  UserRole? userRoleCreationType;
  Widget? form;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    if (widget.extra.selectedUserType.isNotEmpty) {
      assert(widget.extra.selectedUserType.length == 1,
          "Cannot request User to add ${widget.extra.selectedUserType.length} or more users at the same time");
      userRoleCreationType = widget.extra.selectedUserType.first;
      switch (userRoleCreationType) {
        case UserRole.teacher:
          form = const AddTeacherWidget();
        case UserRole.student:
          form = const AddStudentWidget();
        case _:
          throw UnimplementedError();
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBarAndroid(),
        body: UniSystemBackgroundDecoration(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: kBodyHorizontalConstraints,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (userRoleCreationType != null)
                          BackButton(
                              onPressed: () => setState(() {
                                    userRoleCreationType = null;
                                  })),
                        Flexible(
                          child: AnimatedTextTitle(
                            widthFactor: 0.8,
                            fontSize: 31,
                            text: switch (userRoleCreationType) {
                              UserRole.student => context.localizations.adminAddStudentPageTitle,
                              UserRole.teacher => context.localizations.adminAddTeacherPageTitle,
                              _ => context.localizations.adminAddUserPageTitle,
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: AnimatedCrossFade(
                        layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                          return Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            fit: StackFit.expand,
                            children: [
                              bottomChild,
                              topChild,
                            ],
                          );
                        },
                        crossFadeState: userRoleCreationType != null ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            QuickAccessIconButton(
                              text: context.localizations.adminQuickAccessAddStudent,
                              icon: const BigIconWithCompanion(mainIcon: Icons.person, companionIcon: Icons.plus_one),
                              onPressed: () {
                                setState(() {
                                  userRoleCreationType = UserRole.student;
                                  form = const AddStudentWidget();
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            QuickAccessIconButton(
                              text: context.localizations.adminQuickAccessAddTeacher,
                              icon: const BigIconWithCompanion(mainIcon: Icons.school, companionIcon: Icons.plus_one),
                              onPressed: () {
                                setState(() {
                                  userRoleCreationType = UserRole.teacher;
                                  form = const AddTeacherWidget();
                                });
                              },
                            ),
                          ],
                        ),
                        secondChild: SingleChildScrollView(
                          padding: EdgeInsets.only(right: PlatformUtil.isWindows ? 31 : 0, top: 2),
                          child: form ?? const SizedBox(),
                        ),
                        duration: Durations.medium1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _handleErrorSnackBarCommonUser(BuildContext context, Exception e) {
  switch (e.toString()) {
    case String error when error.contains("409") && error.contains("government_id_is_unique"):
      return context.showSnackBar(context.localizations.adminAddUserConflictGovId);
    case String error when error.contains("409") && error.contains("username_is_unique"):
      return context.showSnackBar(context.localizations.adminAddUserConflictUsername);
    case String error when error.contains("409") && error.contains("email_is_unique"):
      return context.showSnackBar(context.localizations.adminAddUserConflictEmail);
  }
  context.showSnackBar(context.localizations.verboseErrorTryAgain);
}

class AddStudentWidget extends ConsumerWidget {
  const AddStudentWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentFormWidget(
      onSubmitCallback: (studentDto) {
        Future<Student> response = ref.read(studentRepositoryProvider).createStudent(studentDto as StudentCreationDto);
        showGeneralDialog(
          barrierLabel: "",
          barrierDismissible: false,
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) {
            return BackgroundWaitModal(future: response);
          },
        );
        response.then((value) {
          ref.invalidate(paginatedUserInfiniteListProvider);
          if (context.mounted) {
            context.goDetailPage(GoRouterRoutes.adminStudentDetail, value);
          }
        }, onError: (e) {
          if (context.mounted) {
            _handleErrorSnackBarCommonUser(context, e);
          }
        });
      },
      buttonContent: Text(context.localizations.adminAddStudentFormSubmitButton),
    );
  }
}

class AddTeacherWidget extends ConsumerWidget {
  const AddTeacherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TeacherFormWidget(
      onSubmitCallback: (teacherDTO) {
        Future<Teacher> response = ref.read(teacherRepositoryProvider).createTeacher(teacherDTO as TeacherCreationDto);
        showGeneralDialog(
          barrierLabel: "",
          barrierDismissible: false,
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) {
            return BackgroundWaitModal(future: response);
          },
        );
        response.then((value) {
          ref.invalidate(paginatedUserInfiniteListProvider);
          if (context.mounted) {
            context.goDetailPage(GoRouterRoutes.adminTeacherDetail, value);
          }
        }, onError: (e) {
          if (context.mounted) {
            _handleErrorSnackBarCommonUser(context, e);
          }
        });
      },
      buttonContent: Text(context.localizations.adminAddTeacherFormSubmitButton),
    );
  }
}
