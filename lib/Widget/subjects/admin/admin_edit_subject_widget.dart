import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Controller/subject/admin_subjects_widget_controller.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/back_button_redirection.dart';
import 'package:university_system_front/Widget/common_components/keyboard_bottom_inset.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/navigation/leading_widgets.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/subjects/subject_form_widget.dart';

class AdminEditSubjectWidget extends ConsumerStatefulWidget {
  final Subject subject;

  const AdminEditSubjectWidget({super.key, required this.subject});

  @override
  ConsumerState<AdminEditSubjectWidget> createState() => _AdminEditSubjectWidgetState();
}

class _AdminEditSubjectWidgetState extends ConsumerState<AdminEditSubjectWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final backRoute = '${GoRouterRoutes.adminSubjects.routeName}/${GoRouterRoutes.adminSubjectDetail.routeName}';

  @override
  Widget build(BuildContext context) {
    return SystemBackButtonRedirection(
      onRedirect: () => context.goDetailPage(GoRouterRoutes.adminSubjectDetail, widget.subject),
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: UniSystemKeyboardBottomInset(
          child: Scaffold(
            appBar: getAppBarAndroid(
              leading: UniSystemCustomBackButton(
                //Windows leading must be configured on router
                route: backRoute,
                extra: widget.subject,
              ),
            ),
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
                                                    ref.read(subjectRepositoryProvider).deleteSubject(widget.subject.name);
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
                                                future.then(
                                                  (value) {
                                                    if (context.mounted) {
                                                      ref.invalidate(paginatedSubjectInfiniteListProvider);
                                                      ref.showTextSnackBar(context.localizations.successfullyDeletedSubject);
                                                      context.popFromModalDialogToParent(GoRouterRoutes.adminEditSubject);
                                                    }
                                                  },
                                                  onError: (e) {
                                                    if (context.mounted) {
                                                      context.popFromDialog();
                                                      if (e is Exception && e.toString().contains("409")) {
                                                        _scaffoldMessengerKey
                                                            .showTextSnackBar(context.localizations.errorDeleteSubjectConflict);
                                                      } else {
                                                        _scaffoldMessengerKey
                                                            .showTextSnackBar(context.localizations.verboseErrorTryAgain);
                                                      }
                                                    }
                                                  },
                                                );
                                              },
                                              child: Text(context.localizations.deleteModalAction)),
                                          TextButton(
                                              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
                              downText: widget.subject.name,
                              upText: context.localizations.editSubject,
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
                          child: SubjectFormWidget(
                            existingSubject: widget.subject,
                            onSubmitCallback: (formSubject) {
                              Future<Subject> response = Future(() async {
                                if (widget.subject.name != formSubject.name) {
                                  try {
                                    await ref.read(subjectRepositoryProvider).getSubject(formSubject.name!);
                                    return Future.error(ArgumentError("Name already exists"));
                                  } catch (e) {
                                    return ref.read(subjectRepositoryProvider).updateSubject(formSubject, widget.subject.name);
                                  }
                                } else {
                                  return ref.read(subjectRepositoryProvider).updateSubject(formSubject, widget.subject.name);
                                }
                              });
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
                                ref.invalidate(paginatedSubjectInfiniteListProvider);
                                if (context.mounted) {
                                  context.goDetailPage(GoRouterRoutes.adminSubjectDetail, value);
                                }
                              }, onError: (e) {
                                if (context.mounted) {
                                  _scaffoldMessengerKey.showTextSnackBar(
                                    e is ArgumentError
                                        ? context.localizations.subjectNameAlreadyExist
                                        : context.localizations.couldNotUpdateSubject,
                                  );
                                }
                              });
                            },
                            buttonContent: Text(context.localizations.updateSubjectButton),
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
      ),
    );
  }
}
