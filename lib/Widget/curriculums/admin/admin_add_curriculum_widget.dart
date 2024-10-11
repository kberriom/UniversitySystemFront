import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Controller/curriculum/admin_curriculum_widget_controller.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Repository/curriculum/curriculum_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/curriculums/curriculum_form_widget.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class AdminAddCurriculumWidget extends ConsumerStatefulWidget {
  const AdminAddCurriculumWidget({super.key});

  @override
  ConsumerState<AdminAddCurriculumWidget> createState() => _AdminAddCurriculumWidgetState();
}

class _AdminAddCurriculumWidgetState extends ConsumerState<AdminAddCurriculumWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedTextTitle(text: context.localizations.adminAddCurriculumTitle),
                      const SizedBox(height: 10),
                      CurriculumFormWidget(
                        onSubmitCallback: (formCurriculum) {
                          Future<Curriculum> response = Future(() async {
                            try {
                              await ref.read(curriculumRepositoryProvider).getCurriculum(formCurriculum.name!);
                              return Future.error(ArgumentError("Name already exists"));
                            } catch (e) {
                              return ref.read(curriculumRepositoryProvider).createCurriculum(formCurriculum);
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
                            ref.invalidate(paginatedCurriculumInfiniteListProvider);
                            if (context.mounted) {
                              context.goDetailPage(GoRouterRoutes.adminCurriculumDetail, value);
                            }
                          }, onError: (e) {
                            if (context.mounted) {
                              showLocalSnackBar(
                                  _scaffoldMessengerKey,
                                  e is ArgumentError
                                      ? context.localizations.curriculumNameAlreadyExist
                                      : context.localizations.couldNotUpdateCurriculum);
                            }
                          });
                        },
                        buttonContent: Text(context.localizations.adminAddCurriculumFormConfirmation),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
