import 'package:flutter/material.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Theme/theme.dart';

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusBig))),
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

class BigIconWithCompanion extends StatefulWidget {
  final IconData mainIcon;
  final IconData? companionIcon;

  const BigIconWithCompanion({
    super.key,
    required this.mainIcon,
    this.companionIcon,
  });

  @override
  State<BigIconWithCompanion> createState() => _BigIconWithCompanionState();
}

class _BigIconWithCompanionState extends State<BigIconWithCompanion> {
  late Brightness _currentThemeMode;
  Color? _mainIconColor;
  late Color _companionColor;

  @override
  void didChangeDependencies() {
    _currentThemeMode = Theme.of(context).brightness;
    _mainIconColor = switch (_currentThemeMode) {
      Brightness.dark => null,
      Brightness.light => Theme.of(context).colorScheme.onSecondaryFixed,
    };
    _companionColor = switch (_currentThemeMode) {
      Brightness.dark => MaterialTheme.darkFilledButton.value,
      Brightness.light => Theme.of(context).colorScheme.onSecondaryFixed,
    };
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(widget.mainIcon, size: 42, color: _mainIconColor),
          if (widget.companionIcon != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(widget.companionIcon, size: 32, color: _companionColor),
            ),
        ],
      ),
    );
  }
}
