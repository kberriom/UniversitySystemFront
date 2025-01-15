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
  final Size bigIconSize;
  final IconData mainIcon;
  final double mainIconSize;
  final IconData? companionIcon;
  final double companionIconSize;
  final Color? mainIconColor;
  final Color? companionIconColor;

  const BigIconWithCompanion({
    super.key,
    required this.mainIcon,
    this.companionIcon,
    this.bigIconSize = const Size(90, 65),
    this.mainIconSize = 42,
    this.companionIconSize = 32,
    this.mainIconColor,
    this.companionIconColor,
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
    if (widget.mainIconColor == null) {
      _mainIconColor = switch (_currentThemeMode) {
        Brightness.dark => null,
        Brightness.light => Theme.of(context).colorScheme.onSecondaryFixed,
      };
    } else {
      _mainIconColor = widget.mainIconColor;
    }
    if (widget.companionIconColor == null) {
      _companionColor = switch (_currentThemeMode) {
        Brightness.dark => MaterialTheme.darkFilledButton.value,
        Brightness.light => Theme.of(context).colorScheme.onSecondaryFixed,
      };
    } else {
      _companionColor = widget.companionIconColor!;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.bigIconSize.height,
      width: widget.bigIconSize.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(widget.mainIcon, size: widget.mainIconSize, color: _mainIconColor),
          if (widget.companionIcon != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(widget.companionIcon, size: widget.companionIconSize, color: _companionColor),
            ),
        ],
      ),
    );
  }
}
