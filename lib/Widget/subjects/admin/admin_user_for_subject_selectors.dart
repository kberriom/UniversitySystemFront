import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/form_widgets.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/Widget/users/admin/admin_user_list_widget.dart';

class SelectStudentForSubjectWidget extends ConsumerWidget {
  final Subject subject;

  const SelectStudentForSubjectWidget({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ItemSelectionModal(
      title: context.localizations.selectStudentForResult,
      child: AdminForResultUserWidget(
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
        },
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
    return ItemSelectionModal(
      title: context.localizations.selectTeacherForResult,
      headerWidget: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _teacherRoleController,
            validator: FormBuilderValidators.required(),
            decoration:
                buildUniSysInputDecoration(context.localizations.teacherRole, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ),
      child: AdminForResultUserWidget(
        filterByStudent: false,
        forResultCallback: (user, role) {
          if (_formKey.currentState?.validate() ?? false) {
            final future =
                ref.read(subjectRepositoryProvider).addTeacher(user.id, widget.subject.name, _teacherRoleController.value.text);
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
                  ref.invalidate(subjectRepositoryProvider);
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
              onError: (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(SnackBar(content: Text(context.localizations.verboseErrorTryAgain)));
                }
              },
            );
          }
        },
      ),
    );
  }
}
