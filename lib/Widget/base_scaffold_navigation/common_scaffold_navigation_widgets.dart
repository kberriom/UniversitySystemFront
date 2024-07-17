import 'package:flutter/material.dart';
import 'package:university_system_front/Util/university_system_ui_localizations_helper.dart';

NavigationDestination buildNavigationDestinationHome(BuildContext context) {
  return NavigationDestination(
      label: context.localizations.navDestHome,
      icon: _getIconWithTooltip(context.localizations.navDestHome, const Icon(Icons.home_outlined)),
      selectedIcon: _getIconWithTooltip(context.localizations.navDestHome, const Icon(Icons.home_filled)));
}

NavigationDestination buildNavigationDestinationUsers(BuildContext context) {
  return NavigationDestination(
      label: context.localizations.navDestUsers,
      icon: _getIconWithTooltip(context.localizations.navDestUsers, const Icon(Icons.person_outline_outlined)),
      selectedIcon: _getIconWithTooltip(context.localizations.navDestUsers, const Icon(Icons.person)));
}

NavigationDestination buildNavigationDestinationSubjects(BuildContext context) {
  return NavigationDestination(
      label: context.localizations.navDestSubjects,
      icon: _getIconWithTooltip(context.localizations.navDestSubjects, const Icon(Icons.collections_bookmark_outlined)),
      selectedIcon: _getIconWithTooltip(context.localizations.navDestSubjects, const Icon(Icons.collections_bookmark)));
}

NavigationDestination buildNavigationDestinationCurriculums(BuildContext context) {
  return NavigationDestination(
      label: context.localizations.navDestCurriculums,
      icon: _getIconWithTooltip(context.localizations.navDestCurriculums, const Icon(Icons.school_outlined)),
      selectedIcon: _getIconWithTooltip(context.localizations.navDestCurriculums, const Icon(Icons.school)));
}

Tooltip _getIconWithTooltip(String message, Icon icon) {
  return Tooltip(message: message, waitDuration: const Duration(milliseconds: 600), child: icon);
}
