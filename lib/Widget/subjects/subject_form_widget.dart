import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/form_widgets.dart';

class SubjectFormWidget extends StatefulWidget {
  final Widget buttonContent;
  final void Function(SubjectDto formSubject) onSubmitCallback;
  final Subject? existingSubject;

  const SubjectFormWidget({this.existingSubject, required this.onSubmitCallback, required this.buttonContent, super.key});

  @override
  State<SubjectFormWidget> createState() => _SubjectFormWidgetState();
}

class _SubjectFormWidgetState extends State<SubjectFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _startDateTextController;
  late final TextEditingController _endDateTextController;
  late final TextEditingController _nameTextController;
  late final TextEditingController _descriptionTextController;
  late final TextEditingController _roomLocationTextController;
  late final TextEditingController _creditsValueController;
  late bool? _isSubjectRemote;
  late bool? _isSubjectOnSite;

  @override
  void initState() {
    _startDateTextController =
        TextEditingController(text: widget.existingSubject?.startDate ?? DateTime.now().toString().substring(0, 10));
    _endDateTextController =
        TextEditingController(text: widget.existingSubject?.endDate ?? DateTime.now().toString().substring(0, 10));
    _nameTextController = TextEditingController(text: widget.existingSubject?.name);
    _descriptionTextController = TextEditingController(text: widget.existingSubject?.description);
    _roomLocationTextController = TextEditingController(text: widget.existingSubject?.roomLocation);
    _creditsValueController = TextEditingController(text: widget.existingSubject?.creditsValue.toString());
    _isSubjectRemote = widget.existingSubject?.remote ?? false;
    _isSubjectOnSite = widget.existingSubject?.onSite ?? false;
    super.initState();
  }

  @override
  void dispose() {
    _startDateTextController.dispose();
    _endDateTextController.dispose();
    _nameTextController.dispose();
    _descriptionTextController.dispose();
    _roomLocationTextController.dispose();
    _creditsValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameTextController,
            validator: FormBuilderValidators.required(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemName, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Wrap(
            runSpacing: 16,
            spacing: 16,
            children: [
              SizedBox(
                width: 260,
                child: UniSysCheckbox(
                  defaultValue: widget.existingSubject?.remote ?? false,
                  text: context.localizations.adminAddSubjectFormItemIsRemote,
                  icon: const Icon(Icons.laptop),
                  valueCallback: (bool? value) => _isSubjectRemote = value!,
                ),
              ),
              SizedBox(
                width: 260,
                child: UniSysCheckbox(
                  defaultValue: widget.existingSubject?.onSite ?? false,
                  text: context.localizations.adminAddSubjectFormItemIsOnSite,
                  icon: const Icon(Icons.home_work),
                  valueCallback: (bool? value) => _isSubjectOnSite = value!,
                ),
              ),
            ],
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
          TextFormField(
              controller: _roomLocationTextController,
              decoration: buildUniSysInputDecoration(
                  context.localizations.adminAddSubjectFormItemRoomLoc, Theme.of(context).colorScheme.onSurfaceVariant)),
          TextFormField(
              controller: _creditsValueController,
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.positiveNumber(),
              decoration: buildUniSysInputDecoration(
                  context.localizations.adminAddSubjectFormItemCreditsValue, Theme.of(context).colorScheme.onSurfaceVariant)),
          FilledButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSubmitCallback.call(_buildSubjectDto());
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

  SubjectDto _buildSubjectDto() {
    return SubjectDto(
      name: _nameTextController.value.text,
      remote: _isSubjectRemote,
      onSite: _isSubjectOnSite,
      description: _descriptionTextController.value.text,
      startDate: _startDateTextController.value.text,
      endDate: _endDateTextController.value.text,
      roomLocation: _roomLocationTextController.value.text,
      creditsValue: int.parse(_creditsValueController.value.text),
    );
  }
}
