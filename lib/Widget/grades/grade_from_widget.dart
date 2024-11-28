import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/form_widgets.dart';

class GradeFormWidget extends ConsumerStatefulWidget {
  final Widget buttonContent;
  final void Function(GradeDto formGrade) onSubmitCallback;
  final StudentSubjectRegistration existingRegistration;
  final GradeDto? existingGrade;
  final bool editOnlyGradeValue;

  const GradeFormWidget({
    super.key,
    required this.existingRegistration,
    this.existingGrade,
    required this.onSubmitCallback,
    required this.buttonContent,
    this.editOnlyGradeValue = false,
  });

  @override
  ConsumerState<GradeFormWidget> createState() => _GradeFormWidgetState();
}

class _GradeFormWidgetState extends ConsumerState<GradeFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _gradeValueTextController;
  late final TextEditingController _percentageOfFinalGradeTextController;
  late final TextEditingController _descriptionTextController;

  @override
  void initState() {
    _gradeValueTextController = TextEditingController(text: widget.existingGrade?.gradeValue);
    _percentageOfFinalGradeTextController = TextEditingController(text: widget.existingGrade?.percentageOfFinalGrade);
    _descriptionTextController = TextEditingController(text: widget.existingGrade?.description);
    super.initState();
  }

  @override
  void dispose() {
    _gradeValueTextController.dispose();
    _percentageOfFinalGradeTextController.dispose();
    _descriptionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            enabled: !widget.editOnlyGradeValue,
            controller: _descriptionTextController,
            maxLines: 1,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.singleLine(),
              FormBuilderValidators.maxWordsCount(4),
              FormBuilderValidators.maxLength(20),
            ]),
            decoration: buildUniSysInputDecoration(
              context.localizations.gradeDescriptionName,
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          TextFormField(
            controller: _gradeValueTextController,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose(
              [FormBuilderValidators.min(0.0, checkNullOrEmpty: false), FormBuilderValidators.max(5.0)],
            ),
            decoration: buildUniSysInputDecoration(
              context.localizations.gradeValueFieldName,
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          TextFormField(
            enabled: !widget.editOnlyGradeValue,
            controller: _percentageOfFinalGradeTextController,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose(
              [FormBuilderValidators.min(0.01, checkNullOrEmpty: false), FormBuilderValidators.max(100)],
            ),
            decoration: buildUniSysInputDecoration(
                    context.localizations.gradePercentageValueFieldName, Theme.of(context).colorScheme.onSurfaceVariant)
                .copyWith(suffixIcon: Icon(Icons.percent_rounded)),
          ),
          FilledButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSubmitCallback.call(_buildGradeDto());
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(100, 50),
              ),
              child: widget.buttonContent),
        ]
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: e,
              ),
            )
            .toList(),
      ),
    );
  }

  GradeDto _buildGradeDto() {
    return GradeDto(
      gradeValue: _gradeValueTextController.value.text,
      percentageOfFinalGrade: _percentageOfFinalGradeTextController.value.text,
      description: _descriptionTextController.value.text,
    );
  }
}
