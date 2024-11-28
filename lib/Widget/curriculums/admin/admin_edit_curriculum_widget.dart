import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Controller/curriculum/admin_curriculum_widget_controller.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Repository/curriculum/curriculum_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/back_button_redirection.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/common_components/keyboard_bottom_inset.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/curriculums/curriculum_form_widget.dart';
import 'package:university_system_front/Widget/navigation/leading_widgets.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class AdminEditCurriculumWidget extends ConsumerStatefulWidget {
  final Curriculum curriculum;

  const AdminEditCurriculumWidget({super.key, required this.curriculum});

  @override
  ConsumerState<AdminEditCurriculumWidget> createState() => _AdminEditCurriculumWidgetState();
}

class _AdminEditCurriculumWidgetState extends ConsumerState<AdminEditCurriculumWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final backRoute = '${GoRouterRoutes.adminCurriculums.routeName}/${GoRouterRoutes.adminCurriculumDetail.routeName}';

  @override
  Widget build(BuildContext context) {
    return SystemBackButtonRedirection(
      onRedirect: () => context.goDetailPage(GoRouterRoutes.adminCurriculumDetail, widget.curriculum),
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: UniSystemKeyboardBottomInset(
          child: Scaffold(
            appBar: getAppBarAndroid(
              leading: UniSystemCustomBackButton(
                //Windows leading must be configured on router
                route: backRoute,
                extra: widget.curriculum,
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
                                                final future = ref
                                                    .read(curriculumRepositoryProvider)
                                                    .deleteCurriculum(widget.curriculum.name);
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
                                                    ref.invalidate(paginatedCurriculumInfiniteListProvider);
                                                    ref.showTextSnackBar(context.localizations.successfullyDeletedCurriculum);

                                                    context.popFromModalDialogToParent(GoRouterRoutes.adminEditCurriculum);
                                                  }
                                                }, onError: (_) {
                                                  if (context.mounted) {
                                                    context.popFromDialog();
                                                    _scaffoldMessengerKey
                                                        .showTextSnackBar(context.localizations.verboseErrorTryAgain);
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
                              downText: widget.curriculum.name,
                              upText: context.localizations.editCurriculum,
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
                          child: CurriculumFormWidget(
                            existingCurriculum: widget.curriculum,
                            onSubmitCallback: (formCurriculum) {
                              Future<Curriculum> response =
                                  ref.read(curriculumRepositoryProvider).updateCurriculum(widget.curriculum.name, formCurriculum);
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
                                ref.invalidate(paginatedCurriculumInfiniteListProvider);
                                if (context.mounted) {
                                  context.goDetailPage(GoRouterRoutes.adminCurriculumDetail, value);
                                }
                              }, onError: (e) {
                                if (context.mounted) {
                                  if (e is Exception) {
                                    switch (e.toString()) {
                                      case String error when error.contains("409"):
                                        _scaffoldMessengerKey.showTextSnackBar(context.localizations.curriculumNameAlreadyExist);
                                    }
                                  } else {
                                    _scaffoldMessengerKey.showTextSnackBar(context.localizations.verboseErrorTryAgain);
                                  }
                                }
                              });
                            },
                            buttonContent: Text(context.localizations.updateCurriculumButton),
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
