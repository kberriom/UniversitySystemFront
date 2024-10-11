import 'package:flutter/material.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';

class CurriculumListItem extends StatelessWidget {
  const CurriculumListItem({
    super.key,
    required this.data,
    required this.itemConstraints,
    this.onPressedCallback,
  });

  final Curriculum data;
  final void Function(Curriculum curriculum)? onPressedCallback;
  final FixedExtentItemConstraints itemConstraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey<int>(data.id),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () {
              if (onPressedCallback != null) {
                onPressedCallback!.call(data);
              } else {
                context.goDetailPage(GoRouterRoutes.adminCurriculumDetail, data);
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
                        child: Text(data.name, overflow: TextOverflow.ellipsis),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Tooltip(message: context.localizations.idTooltip, child: const Icon(Icons.badge_outlined)),
                            const SizedBox(width: 5),
                            Text("${data.id}"),
                            const SizedBox(width: 5),
                            Tooltip(message: context.localizations.dateTooltip, child: const Icon(Icons.calendar_month_sharp)),
                            const SizedBox(width: 5),
                            Text('${data.dateStart} — ${data.dateEnd}', overflow: TextOverflow.ellipsis),
                          ],
                        ),
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
