import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/form_widgets.dart';

class CurriculumFormWidget extends StatefulWidget {
  final Widget buttonContent;
  final void Function(CurriculumDTO formCurriculum) onSubmitCallback;
  final Curriculum? existingCurriculum;

  const CurriculumFormWidget({super.key, this.existingCurriculum, required this.onSubmitCallback, required this.buttonContent});

  @override
  State<CurriculumFormWidget> createState() => _CurriculumFormWidgetState();
}

class _CurriculumFormWidgetState extends State<CurriculumFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _startDateTextController;
  late final TextEditingController _endDateTextController;
  late final TextEditingController _nameTextController;
  late final TextEditingController _descriptionTextController;

  @override
  void initState() {
    _startDateTextController =
        TextEditingController(text: widget.existingCurriculum?.dateStart ?? DateTime.now().toString().substring(0, 10));
    _endDateTextController =
        TextEditingController(text: widget.existingCurriculum?.dateEnd ?? DateTime.now().toString().substring(0, 10));
    _nameTextController = TextEditingController(text: widget.existingCurriculum?.name);
    _descriptionTextController = TextEditingController(text: widget.existingCurriculum?.description);
    super.initState();
  }

  @override
  void dispose() {
    _startDateTextController.dispose();
    _endDateTextController.dispose();
    _nameTextController.dispose();
    _descriptionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          TextFormField(
            controller: _nameTextController,
            validator: FormBuilderValidators.required(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemName, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            minLines: 3,
            maxLines: 3,
            controller: _descriptionTextController,
            validator: FormBuilderValidators.required(),
            decoration: buildUniSysInputDecoration(
                context.localizations.formItemDescription, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 160,
                child: UniSysDateSelector(
                  label: context.localizations.adminAddFormItemStartDate,
                  textEditingController: _startDateTextController,
                  validator: FormBuilderValidators.date(),
                ),
              ),
              SizedBox(
                width: 160,
                child: UniSysDateSelector(
                  label: context.localizations.adminAddFormItemEndDate,
                  textEditingController: _endDateTextController,
                  validator: FormBuilderValidators.date(),
                ),
              ),
            ],
          ),
          FilledButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSubmitCallback.call(CurriculumDTO(
                    name: _nameTextController.value.text,
                    description: _descriptionTextController.value.text,
                    dateStart: _startDateTextController.value.text,
                    dateEnd: _endDateTextController.value.text,
                  ));
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(100, 50),
              ),
              child: widget.buttonContent),
        ],
      ),
    );
  }
}
