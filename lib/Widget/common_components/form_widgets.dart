import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:university_system_front/Util/localization_utils.dart';

InputDecoration buildUniSysInputDecoration(String label, Color borderColor) {
  return InputDecoration(
    labelText: label,
    alignLabelWithHint: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: borderColor),
    ),
    border: const OutlineInputBorder(
      borderSide: BorderSide.none,
    ),
    filled: true,
  );
}

class UniSysPasswordInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool enabled;
  final String label;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onEditingComplete;

  const UniSysPasswordInput({
    super.key,
    required this.textEditingController,
    this.enabled = true,
    required this.label,
    this.validator,
    this.onEditingComplete,
  });

  @override
  State<UniSysPasswordInput> createState() => _UniSysPasswordInputState();
}

class _UniSysPasswordInputState extends State<UniSysPasswordInput> {
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      onEditingComplete: widget.onEditingComplete,
      controller: widget.textEditingController,
      obscureText: _isPasswordObscured,
      enableSuggestions: false,
      autocorrect: false,
      validator: widget.validator ?? FormBuilderValidators.password(),
      decoration: buildUniSysInputDecoration(widget.label, Theme.of(context).colorScheme.onSurfaceVariant).copyWith(
        suffixIcon: Tooltip(
          message: _isPasswordObscured
              ? context.localizations.passwordFieldShowTooltip
              : context.localizations.passwordFieldHideTooltip,
          child: IconButton(
            onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
            icon: _getPasswordVisibilityIcon(),
          ),
        ),
      ),
    );
  }

  Widget _getPasswordVisibilityIcon() {
    if (_isPasswordObscured) {
      return const Icon(Icons.remove_red_eye);
    }
    return const Icon(Icons.remove_red_eye_outlined);
  }
}

class UniSysCheckbox extends StatefulWidget {
  final Icon? icon;
  final String? text;

  ///value is never null checkbox is not triState, default value is false
  final void Function(bool? value) valueCallback;
  final bool defaultValue;

  const UniSysCheckbox({
    super.key,
    this.icon,
    this.text,
    required this.valueCallback,
    this.defaultValue = false,
  });

  @override
  State<UniSysCheckbox> createState() => _UniSysCheckboxState();
}

class _UniSysCheckboxState extends State<UniSysCheckbox> {
  var value = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      tristate: false,
      secondary: widget.icon,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      controlAffinity: ListTileControlAffinity.leading,
      title: widget.text != null
          ? Text(
              widget.text!,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            )
          : null,
      value: value,
      onChanged: (value) {
        widget.valueCallback.call(value);
        setState(() {
          this.value = value!;
        });
      },
    );
  }

  @override
  void initState() {
    value = widget.defaultValue;
    super.initState();
  }
}

class UniSysDateSelector extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;
  final FormFieldValidator<String>? validator;
  final bool requireDateNowOrFuture;
  final bool enabled;

  const UniSysDateSelector({
    super.key,
    required this.textEditingController,
    required this.label,
    this.validator,
    this.enabled = true,
    this.requireDateNowOrFuture = true,
  });

  @override
  State<UniSysDateSelector> createState() => _UniSysDateSelectorState();
}

class _UniSysDateSelectorState extends State<UniSysDateSelector> {
  final DateTime now = DateTime.now();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      keyboardType: TextInputType.datetime,
      validator: widget.validator ??
          FormBuilderValidators.compose([
            FormBuilderValidators.date(errorText: context.localizations.dateFieldValidRequired),
            FormBuilderValidators.dateRange(
                widget.requireDateNowOrFuture ? DateTime(now.year, now.month, now.day) : DateTime(1800), DateTime(9999),
                errorText: context.localizations.dateFieldValidRequired),
          ]),
      controller: widget.textEditingController,
      decoration: InputDecoration(
        prefixIcon: IconButton(
            onPressed: () async => showDatePicker(
                        context: context,
                        currentDate: selectedDate,
                        firstDate: widget.requireDateNowOrFuture ? now : DateTime(1800),
                        lastDate: DateTime(9999))
                    .then((value) {
                  if (value != null) {
                    widget.textEditingController.text = value.toString().substring(0, 10);
                    setState(() {
                      selectedDate = value;
                    });
                  }
                }),
            icon: const Icon(Icons.calendar_month)),
        labelText: widget.label,
        errorMaxLines: 2,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        filled: true,
      ),
    );
  }
}
