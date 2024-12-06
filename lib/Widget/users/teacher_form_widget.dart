import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/form_widgets.dart';

class TeacherFormWidget extends StatefulWidget {
  final Widget buttonContent;
  final void Function(Object teacherDto) onSubmitCallback;
  final Teacher? existingTeacher;
  final ScrollController? scrollController;

  const TeacherFormWidget({
    super.key,
    this.existingTeacher,
    required this.onSubmitCallback,
    required this.buttonContent,
    this.scrollController,
  });

  @override
  State<TeacherFormWidget> createState() => _TeacherFormWidgetState();
}

class _TeacherFormWidgetState extends State<TeacherFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameTextController;
  late final TextEditingController _lastNameTextController;
  late final TextEditingController _governmentIdTextController;
  late final TextEditingController _emailTextController;
  late final TextEditingController _mobilePhoneTextController;
  late final TextEditingController _landPhoneTextController;
  late final TextEditingController _birthdateTextController;
  late final TextEditingController _usernameTextController;
  late final TextEditingController _departmentTextController;
  late final TextEditingController _passwordTextController = TextEditingController();
  late final TextEditingController _confirmPasswordTextController = TextEditingController();
  bool adminPasswordEditMode = false;

  @override
  void initState() {
    _nameTextController = TextEditingController(text: widget.existingTeacher?.name);
    _lastNameTextController = TextEditingController(text: widget.existingTeacher?.lastName);
    _governmentIdTextController = TextEditingController(text: widget.existingTeacher?.governmentId);
    _emailTextController = TextEditingController(text: widget.existingTeacher?.email);
    _mobilePhoneTextController = TextEditingController(text: widget.existingTeacher?.mobilePhone);
    _landPhoneTextController = TextEditingController(text: widget.existingTeacher?.landPhone);
    _birthdateTextController = TextEditingController(text: widget.existingTeacher?.birthdate);
    _usernameTextController = TextEditingController(text: widget.existingTeacher?.username);
    _departmentTextController = TextEditingController(text: widget.existingTeacher?.department);
    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _lastNameTextController.dispose();
    _governmentIdTextController.dispose();
    _emailTextController.dispose();
    _mobilePhoneTextController.dispose();
    _landPhoneTextController.dispose();
    _birthdateTextController.dispose();
    _usernameTextController.dispose();
    _departmentTextController.dispose();
    _passwordTextController.dispose();
    _confirmPasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.existingTeacher != null)
            SwitchListTile(
              title: Text(context.localizations.adminPassEditMode),
              value: adminPasswordEditMode,
              onChanged: (stateValue) {
                if (stateValue) {
                  widget.scrollController?.animateTo(999, duration: Durations.short4, curve: Curves.easeInCubic);
                }
                setState(() => adminPasswordEditMode = !adminPasswordEditMode);
              },
            ),
          TextFormField(
            enabled: !adminPasswordEditMode,
            controller: _nameTextController,
            validator: FormBuilderValidators.required(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemName, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            enabled: !adminPasswordEditMode,
            controller: _lastNameTextController,
            validator: FormBuilderValidators.required(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemLastName, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            enabled: !adminPasswordEditMode,
            controller: _departmentTextController,
            validator: FormBuilderValidators.required(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemDepartment, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            enabled: widget.existingTeacher == null && !adminPasswordEditMode,
            controller: _governmentIdTextController,
            onChanged: (value) => _governmentIdTextController.text = value.replaceAll(" ", "").replaceAll("-", "").replaceAll(".", ""),
            validator: FormBuilderValidators.numeric(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemGovId, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            enabled: widget.existingTeacher == null && !adminPasswordEditMode,
            controller: _emailTextController,
            validator: FormBuilderValidators.email(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemEmail, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            enabled: !adminPasswordEditMode,
            keyboardType: TextInputType.phone,
            controller: _mobilePhoneTextController,
            validator: FormBuilderValidators.aggregate([
              FormBuilderValidators.phoneNumber(checkNullOrEmpty: false),
              (input) {
                if (_landPhoneTextController.value.text.isEmpty && _mobilePhoneTextController.value.text.isEmpty) {
                  return context.localizations.adminAddFormItemPhoneValidator;
                } else {
                  return null;
                }
              }
            ]),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemCellPhone, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            enabled: !adminPasswordEditMode,
            keyboardType: TextInputType.phone,
            controller: _landPhoneTextController,
            validator: FormBuilderValidators.aggregate([
              FormBuilderValidators.phoneNumber(checkNullOrEmpty: false),
              (input) {
                if (_landPhoneTextController.value.text.isEmpty && _mobilePhoneTextController.value.text.isEmpty) {
                  return context.localizations.adminAddFormItemPhoneValidator;
                } else {
                  return null;
                }
              }
            ]),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemLandline, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          UniSysDateSelector(
            enabled: widget.existingTeacher == null && !adminPasswordEditMode,
            requireDateNowOrFuture: false,
            textEditingController: _birthdateTextController,
            label: context.localizations.adminAddFormItemBirthdate,
            validator: FormBuilderValidators.datePast(),
          ),
          TextFormField(
            enabled: widget.existingTeacher == null && !adminPasswordEditMode,
            controller: _usernameTextController,
            validator: FormBuilderValidators.username(allowNumbers: true, allowSpecialChar: true, allowDots: true),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemUsername, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          UniSysPasswordInput(
            enabled: widget.existingTeacher == null || adminPasswordEditMode,
            textEditingController: _passwordTextController,
            validator: FormBuilderValidators.aggregate([
              if (widget.existingTeacher == null || adminPasswordEditMode) FormBuilderValidators.required(),
              FormBuilderValidators.password(checkNullOrEmpty: false),
            ]),
            label: context.localizations.adminAddFormItemPassword,
          ),
          UniSysPasswordInput(
            enabled: widget.existingTeacher == null || adminPasswordEditMode,
            textEditingController: _confirmPasswordTextController,
            label: context.localizations.adminAddFormItemConfirmPassword,
            validator: (input) {
              if (_passwordTextController.value.text != _confirmPasswordTextController.value.text) {
                return context.localizations.adminAddFormItemConfirmPasswordValidator;
              } else {
                return null;
              }
            },
          ),
          FilledButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  if (widget.existingTeacher == null) {
                    widget.onSubmitCallback.call(
                      TeacherCreationDto(
                        name: _nameTextController.value.text,
                        lastName: _lastNameTextController.value.text,
                        governmentId: _governmentIdTextController.value.text,
                        email: _emailTextController.value.text,
                        mobilePhone: _mobilePhoneTextController.value.text,
                        landPhone: _landPhoneTextController.value.text,
                        birthdate: _birthdateTextController.value.text,
                        username: _usernameTextController.value.text,
                        department: _departmentTextController.value.text,
                        userPassword: _passwordTextController.value.text,
                      ),
                    );
                  } else {
                    if (adminPasswordEditMode) {
                      widget.onSubmitCallback.call(
                        AdminPasswordUpdateDto(
                          email: widget.existingTeacher!.email,
                          newPassword: _passwordTextController.value.text,
                        ),
                      );
                    }
                    widget.onSubmitCallback.call(
                      TeacherUpdateDto(
                        name: _nameTextController.value.text,
                        lastName: _lastNameTextController.value.text,
                        mobilePhone: _mobilePhoneTextController.value.text,
                        landPhone: _landPhoneTextController.value.text,
                        department: _departmentTextController.value.text,
                      ),
                    );
                  }
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
}
