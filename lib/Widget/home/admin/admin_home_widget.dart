import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Theme/theme.dart';
import 'package:university_system_front/Theme/theme_mode_provider.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/common_components/scaffold_background_decoration.dart';
import 'package:university_system_front/Widget/home/common_home_widgets.dart';

class AdminHomeWidget extends ConsumerStatefulWidget {
  const AdminHomeWidget({super.key});

  @override
  ConsumerState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<AdminHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarAndroid(),
      body: ScaffoldBackgroundDecoration(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HomeTextTitle(text: context.localizations.upperCaseHomeTitleAndUserName('ADMIN')),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.localizations.homeQuickAccess, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 18),
                        QuickAccessIconButton(
                          text: context.localizations.adminQuickAccessAddStudent,
                          icon: const BigIconWithCompanion(mainIcon: Icons.person, companionIcon: Icons.plus_one),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 18),
                        QuickAccessIconButton(
                          text: context.localizations.adminQuickAccessAddTeacher,
                          icon: const BigIconWithCompanion(mainIcon: Icons.school, companionIcon: Icons.plus_one),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 18),
                        QuickAccessIconButton(
                          text: context.localizations.adminQuickAccessCalGrades,
                          icon: const BigIconWithCompanion(mainIcon: Icons.grading),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAccessIconButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const QuickAccessIconButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
      onPressed: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 600, minHeight: 80, maxHeight: 80),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontSize: 24)),
            const Spacer(),
            icon,
          ],
        ),
      ),
    );
  }
}

class BigIconWithCompanion extends ConsumerWidget {
  final IconData mainIcon;
  final IconData? companionIcon;

  const BigIconWithCompanion({
    super.key,
    required this.mainIcon,
    this.companionIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentThemeMode = ref.watch(currentThemeModeProvider);

    Color? mainIconColor;
    if (currentThemeMode == ThemeMode.light) {
      mainIconColor = Theme.of(context).colorScheme.onSecondaryFixed;
    } else {
      mainIconColor = null;
    }

    Color companionColor;
    if (currentThemeMode == ThemeMode.light) {
      companionColor = Theme.of(context).colorScheme.onSecondaryFixed;
    } else {
      companionColor = MaterialTheme.darkFilledButton.value;
    }

    return SizedBox(
      height: 65,
      width: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(mainIcon, size: 42, color: mainIconColor),
          if (companionIcon != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(companionIcon, size: 32, color: companionColor),
            ),
        ],
      ),
    );
  }
}
