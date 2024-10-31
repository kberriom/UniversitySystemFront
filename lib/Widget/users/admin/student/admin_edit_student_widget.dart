import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Controller/users/admin_users_widget_controller.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Repository/users/student_repository.dart';
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
import 'package:university_system_front/Widget/users/student_form_widget.dart';

class AdminEditStudentWidget extends ConsumerStatefulWidget {
  final Student student;

  const AdminEditStudentWidget({super.key, required this.student});

  @override
  ConsumerState<AdminEditStudentWidget> createState() => _AdminEditStudentWidgetState();
}

class _AdminEditStudentWidgetState extends ConsumerState<AdminEditStudentWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          PlatformUtil.isAndroid ? context.goDetailPage(GoRouterRoutes.adminStudentDetail, widget.student) : null,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: getAppBarAndroid(
              leading: UniSystemCloseButton(routerRoute: GoRouterRoutes.adminStudentDetail, extra: widget.student)),
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
                                                  ref.read(studentRepositoryProvider).deleteUserTypeInfoById(widget.student.id);
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
                                                  ref.showGlobalSnackBar(context.localizations.adminStudentDeleteSuccess);

                                                  context.popFromModalDialogToParent(GoRouterRoutes.adminEditStudent);
                                                }
                                              }, onError: (e) {
                                                if (context.mounted) {
                                                  context.popFromDialog();
                                                  if (e is Exception && e.toString().contains("409")) {
                                                    return showLocalSnackBar(
                                                        _scaffoldMessengerKey, context.localizations.errorDeleteStudentConflict);
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
                            downText: widget.student.name,
                            upText: context.localizations.adminEditStudentPageTitle,
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
                        child: StudentFormWidget(
                          existingStudent: widget.student,
                          onSubmitCallback: (formStudent) {
                            Future<Student> response = ref
                                .read(studentRepositoryProvider)
                                .updateUserTypeInfoById(widget.student.id, formStudent as StudentUpdateDto);
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
                                context.goDetailPage(GoRouterRoutes.adminStudentDetail, value);
                              }
                            }, onError: (e) {
                              if (context.mounted) {
                                showLocalSnackBar(_scaffoldMessengerKey, context.localizations.verboseErrorTryAgain);
                              }
                            });
                          },
                          buttonContent: Text(context.localizations.adminEditStudentFormSubmitButton),
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
