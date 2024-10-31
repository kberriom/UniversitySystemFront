import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/form_widgets.dart';

class StudentFormWidget extends StatefulWidget {
  final Widget buttonContent;
  final void Function(Object studentDto) onSubmitCallback;
  final Student? existingStudent;

  const StudentFormWidget({super.key, this.existingStudent, required this.onSubmitCallback, required this.buttonContent});

  @override
  State<StudentFormWidget> createState() => _StudentFormWidgetState();
}

class _StudentFormWidgetState extends State<StudentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameTextController;
  late final TextEditingController _lastNameTextController;
  late final TextEditingController _governmentIdTextController;
  late final TextEditingController _emailTextController;
  late final TextEditingController _mobilePhoneTextController;
  late final TextEditingController _landPhoneTextController;
  late final TextEditingController _birthdateTextController;
  late final TextEditingController _usernameTextController;
  late final TextEditingController _passwordTextController = TextEditingController();
  late final TextEditingController _confirmPasswordTextController = TextEditingController();

  @override
  void initState() {
    _nameTextController = TextEditingController(text: widget.existingStudent?.name);
    _lastNameTextController = TextEditingController(text: widget.existingStudent?.lastName);
    _governmentIdTextController = TextEditingController(text: widget.existingStudent?.governmentId);
    _emailTextController = TextEditingController(text: widget.existingStudent?.email);
    _mobilePhoneTextController = TextEditingController(text: widget.existingStudent?.mobilePhone);
    _landPhoneTextController = TextEditingController(text: widget.existingStudent?.landPhone);
    _birthdateTextController = TextEditingController(text: widget.existingStudent?.birthdate);
    _usernameTextController = TextEditingController(text: widget.existingStudent?.username);
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
          TextFormField(
            controller: _nameTextController,
            validator: FormBuilderValidators.required(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemName, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            controller: _lastNameTextController,
            validator: FormBuilderValidators.required(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemLastName, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            enabled: widget.existingStudent == null,
            controller: _governmentIdTextController,
            validator: FormBuilderValidators.numeric(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemGovId, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            enabled: widget.existingStudent == null,
            controller: _emailTextController,
            validator: FormBuilderValidators.email(),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemEmail, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          TextFormField(
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
            enabled: widget.existingStudent == null,
            requireDateNowOrFuture: false,
            textEditingController: _birthdateTextController,
            label: context.localizations.adminAddFormItemBirthdate,
            validator: FormBuilderValidators.datePast(),
          ),
          TextFormField(
            enabled: widget.existingStudent == null,
            controller: _usernameTextController,
            validator: FormBuilderValidators.username(allowNumbers: true, allowSpecialChar: true),
            decoration: buildUniSysInputDecoration(
                context.localizations.adminAddFormItemUsername, Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          UniSysPasswordInput(
            enabled: widget.existingStudent == null,
            textEditingController: _passwordTextController,
            validator: FormBuilderValidators.aggregate([
              if (widget.existingStudent == null) FormBuilderValidators.required(),
              if (widget.existingStudent == null) FormBuilderValidators.password(checkNullOrEmpty: false),
            ]),
            label: context.localizations.adminAddFormItemPassword,
          ),
          UniSysPasswordInput(
            enabled: widget.existingStudent == null,
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
                  if (widget.existingStudent == null) {
                    widget.onSubmitCallback.call(
                      StudentCreationDto(
                        name: _nameTextController.value.text,
                        lastName: _lastNameTextController.value.text,
                        governmentId: _governmentIdTextController.value.text,
                        email: _emailTextController.value.text,
                        mobilePhone: _mobilePhoneTextController.value.text,
                        landPhone: _landPhoneTextController.value.text,
                        birthdate: _birthdateTextController.value.text,
                        username: _usernameTextController.value.text,
                        userPassword: _passwordTextController.value.text,
                      ),
                    );
                  } else {
                    widget.onSubmitCallback.call(
                      StudentUpdateDto(
                        name: _nameTextController.value.text,
                        lastName: _lastNameTextController.value.text,
                        mobilePhone: _mobilePhoneTextController.value.text,
                        landPhone: _landPhoneTextController.value.text,
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
