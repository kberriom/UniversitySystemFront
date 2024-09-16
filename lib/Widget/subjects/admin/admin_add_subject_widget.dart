import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Controller/subject/admin_subjects_widget_controller.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Widget/common_components/animated_text_title.dart';
import 'package:university_system_front/Widget/common_components/modals.dart';
import 'package:university_system_front/Widget/common_components/scaffold_background_decoration.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/subjects/subject_form_widget.dart';

class AddSubjectWidget extends ConsumerStatefulWidget {
  const AddSubjectWidget({super.key});

  @override
  ConsumerState<AddSubjectWidget> createState() => _AddSubjectWidgetState();
}

class _AddSubjectWidgetState extends ConsumerState<AddSubjectWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBarAndroid(),
        body: ScaffoldBackgroundDecoration(
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
                      AnimatedTextTitle(text: context.localizations.adminAddSubjectTitle),
                      const SizedBox(height: 10),
                      SubjectFormWidget(
                        onSubmitCallback: (formSubject) {
                          Future<Subject> response = Future(() async {
                            try {
                              await ref.read(subjectRepositoryProvider).getSubject(formSubject.name!);
                              return Future.error(ArgumentError("Name already exists"));
                            } catch (e) {
                              return ref.read(subjectRepositoryProvider).createSubject(formSubject);
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
                              GoRouter.of(context).pushReplacement(
                                  '${GoRouterRoutes.adminSubjects.routeName}/${GoRouterRoutes.adminSubjectDetail.routeName}',
                                  extra: value);
                            }
                          }, onError: (e) {
                            if (context.mounted) {
                              context.showLocalSnackBar(
                                  _scaffoldMessengerKey,
                                  e is ArgumentError
                                      ? context.localizations.subjectNameAlreadyExist
                                      : context.localizations.couldNotUpdateSubject);
                            }
                          });
                        },
                        buttonContent: Text(context.localizations.adminAddSubjectFormConfirmation),
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
