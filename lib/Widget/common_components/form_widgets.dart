import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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

  const UniSysDateSelector({
    super.key,
    required this.textEditingController,
    required this.label,
    this.validator,
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
      keyboardType: TextInputType.datetime,
      validator: widget.validator ??
          FormBuilderValidators.compose([
            FormBuilderValidators.date(errorText: "Valid date required"),
            FormBuilderValidators.dateRange(DateTime(now.year, now.month, now.day), DateTime(9999),
                errorText: "Valid date required"),
          ]),
      controller: widget.textEditingController,
      decoration: InputDecoration(
        prefixIcon: IconButton(
            onPressed: () async =>
                showDatePicker(context: context, currentDate: selectedDate, firstDate: now, lastDate: DateTime(9999))
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
