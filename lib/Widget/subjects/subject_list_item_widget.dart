import 'package:flutter/material.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Util/string_utils.dart';
import 'package:university_system_front/Widget/common_components/animated_text_overflow.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';

class SubjectListItem extends StatelessWidget {
  const SubjectListItem({
    super.key,
    required this.data,
    required this.itemConstraints,
    this.onPressedCallback,
  });

  final Subject data;
  final void Function(Subject subject)? onPressedCallback;
  final FixedExtentItemConstraints itemConstraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey<int>(data.id),
      padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: itemConstraints.cardMinWidthConstraints,
              maxWidth: itemConstraints.cardMaxWidthConstraints,
              minHeight: itemConstraints.cardHeight,
              maxHeight: itemConstraints.cardHeight),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.only(left: 24, right: 17),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () {
              if (onPressedCallback != null) {
                onPressedCallback!.call(data);
              } else {
                context.goDetailPage(GoRouterRoutes.adminSubjectDetail, data);
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: AnimatedTextOverFlow(
                          child: Text(
                            data.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Tooltip(message: context.localizations.dateTooltip, child: const Icon(Icons.calendar_month_sharp)),
                            const SizedBox(width: 5),
                            Text('${data.startDate} — ${data.endDate}', overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.location_on),
                      Text(
                        replaceOnEmptyOrNull(data.roomLocation, context.localizations.adminSubjectListNoRoomAssigned),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
