import 'package:flutter/material.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class TeacherHomeWidget extends StatelessWidget {
  const TeacherHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DynamicUniSystemAppBar(isInLogin: false),
      body: UniSystemBackgroundDecoration(
        child: Placeholder(
          child: Center(
            child: Text(context.localizations.teacherItemName),
          ),
        ),
      ),
    );
  }
}
