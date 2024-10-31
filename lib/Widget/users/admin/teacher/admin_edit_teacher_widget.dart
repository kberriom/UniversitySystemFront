import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Controller/users/admin_users_widget_controller.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Repository/users/teacher_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/navigation/leading_widgets.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/users/teacher_form_widget.dart';

class AdminEditTeacherWidget extends ConsumerStatefulWidget {
  final Teacher teacher;

  const AdminEditTeacherWidget({super.key, required this.teacher});

  @override
  ConsumerState<AdminEditTeacherWidget> createState() => _AdminEditTeacherWidgetState();
}

class _AdminEditTeacherWidgetState extends ConsumerState<AdminEditTeacherWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          PlatformUtil.isAndroid ? context.goDetailPage(GoRouterRoutes.adminTeacherDetail, widget.teacher) : null,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: getAppBarAndroid(
              leading: UniSystemCloseButton(routerRoute: GoRouterRoutes.adminTeacherDetail, extra: widget.teacher)),
          body: UniSystemBackgroundDecoration(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: ConstrainedBox(
                    constraints: kBodyHorizontalConstraints,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return DialogModal(
                                    canPop: true,
                                    child: AlertDialog(
                                      title: Text(context.localizations.modalDeleteWarningTitle),
                                      content: Text(context.localizations.modalDeleteWarningContent),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              final future =
                                                  ref.read(teacherRepositoryProvider).deleteUserTypeInfoById(widget.teacher.id);
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
                                                  ref.invalidate(paginatedUserInfiniteListProvider);
                                                  ref.showGlobalSnackBar(context.localizations.adminTeacherDeleteSuccess);

                                                  context.popFromModalDialogToParent(GoRouterRoutes.adminEditTeacher);
                                                }
                                              }, onError: (e) {
                                                if (context.mounted) {
                                                  context.popFromDialog();
                                                  if (e is Exception && e.toString().contains("409")) {
                                                    return showLocalSnackBar(
                                                        _scaffoldMessengerKey, context.localizations.errorDeleteTeacherConflict);
                                                  }
                                                  showLocalSnackBar(
                                                      _scaffoldMessengerKey, context.localizations.verboseErrorTryAgain);
                                                }
                                              });
                                            },
                                            child: Text(context.localizations.deleteModalAction)),
                                        TextButton(
                                            onPressed: () => context.popFromDialog(),
                                            child: Text(context.localizations.cancelModalAction))
                                      ],
                                    ),
                                  );
                                });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                        Flexible(
                          child: AnimatedComboTextTitle(
                            widthFactor: 0.9,
                            downText: widget.teacher.name,
                            upText: context.localizations.adminEditTeacherPageTitle,
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
                      padding: const EdgeInsets.only(left: kBodyHorizontalPadding, right: kBodyHorizontalPadding, top: 10),
                      child: ConstrainedBox(
                        constraints: kBodyHorizontalConstraints,
                        child: TeacherFormWidget(
                          existingTeacher: widget.teacher,
                          onSubmitCallback: (formTeacher) {
                            Future<Teacher> response = ref
                                .read(teacherRepositoryProvider)
                                .updateUserTypeInfoById(widget.teacher.id, formTeacher as TeacherUpdateDto);
                            showGeneralDialog(
                              barrierLabel: "",
                              barrierDismissible: false,
                              context: context,
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return BackgroundWaitModal(
                                  future: response,
                                );
                              },
                            );
                            response.then((value) {
                              //On edit successful
                              ref.invalidate(paginatedUserInfiniteListProvider);
                              if (context.mounted) {
                                context.goDetailPage(GoRouterRoutes.adminTeacherDetail, value);
                              }
                            }, onError: (e) {
                              if (context.mounted) {
                                showLocalSnackBar(_scaffoldMessengerKey, context.localizations.verboseErrorTryAgain);
                              }
                            });
                          },
                          buttonContent: Text(context.localizations.adminEditTeacherFormSubmitButton),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
