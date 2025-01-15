import 'package:flutter/material.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/detail_page_widgets.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';

class AdminUserDetail extends StatelessWidget {
  final User user;
  final String headerTitle;
  final List<Widget> underlineBannerWidgets;
  final List<Widget> bodyWidgets;

  const AdminUserDetail({
    super.key,
    required this.user,
    required this.headerTitle,
    this.underlineBannerWidgets = const [],
    this.bodyWidgets = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UniSystemDetailHeader(
          header: AnimatedComboTextTitle(
            widthFactor: 0.9,
            upText: headerTitle,
            downText: "${user.name} ${user.lastName}",
            underlineWidget: UserUnderlineInfo(
              user: user,
              widgets: underlineBannerWidgets,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ExpansionTile(
          collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          collapsedShape: const RoundedRectangleBorder(),
          shape: const RoundedRectangleBorder(),
          title: Text(context.localizations.detailSeeMoreInfo),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          children: <Widget>[
            ListTile(
              title: Text("${context.localizations.adminAddFormItemGovId}: ${user.governmentId}"),
            ),
            ListTile(
              title: Text("${context.localizations.adminAddFormItemEmail}: ${user.email}"),
            ),
            ListTile(
              title: Text(
                  "${context.localizations.adminAddFormItemCellPhone}: ${(user.mobilePhone ?? "").isEmpty ? context.localizations.adminAddFormItemNotRegistered : user.mobilePhone}"),
            ),
            ListTile(
              title: Text(
                  "${context.localizations.adminAddFormItemLandline}: ${(user.landPhone ?? "").isEmpty ? context.localizations.adminAddFormItemNotRegistered : user.landPhone}"),
            ),
            ListTile(
              title: Text("${context.localizations.adminAddFormItemBirthdate}: ${user.birthdate}"),
            ),
            ListTile(
              title: Text("${context.localizations.adminAddFormItemEnrollmentDate}: ${user.enrollmentDate}"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...bodyWidgets,
      ],
    );
  }
}

class UserUnderlineInfo extends StatelessWidget {
  final User user;
  final List<Widget> widgets;

  const UserUnderlineInfo({
    super.key,
    required this.user,
    required this.widgets,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Tooltip(message: context.localizations.idTooltip, child: const Icon(Icons.badge_outlined)),
        Text("${user.id}"),
        Tooltip(message: context.localizations.usernameTooltip, child: const Icon(Icons.account_circle)),
        Text(user.username),
        ...widgets,
      ],
    );
  }
}
