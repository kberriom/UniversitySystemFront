import 'package:flutter/material.dart';
import 'package:university_system_front/Widget/common_components/scaffold_background_decoration.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class AddSubjectWidget extends StatefulWidget {
  const AddSubjectWidget({super.key});

  @override
  State<AddSubjectWidget> createState() => _AddSubjectWidgetState();
}

class _AddSubjectWidgetState extends State<AddSubjectWidget> {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBarAndroid(),
        body: ScaffoldBackgroundDecoration(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Placeholder(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
