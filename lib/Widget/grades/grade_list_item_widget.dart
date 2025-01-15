import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:university_system_front/Model/grade.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/animated_text_overflow.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart' as title;

class GradeListItem extends StatelessWidget {
  const GradeListItem({
    super.key,
    required this.data,
    required this.itemConstraints,
    this.onPressedCallback,
    this.subjectName,
    this.onDeleteCallback,
  });

  final Grade data;
  final String? subjectName;
  final void Function(Grade grade)? onPressedCallback;
  final VoidCallback? onDeleteCallback;
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
              splashFactory: NoSplash.splashFactory,
              overlayColor: Colors.transparent,
              enableFeedback: false,
              enabledMouseCursor: MouseCursor.defer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () {
              if (onPressedCallback != null) {
                onPressedCallback!.call(data);
              }
            },
            child: SizedBox.expand(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (subjectName != null)
                          AnimatedTextOverFlow(
                            child: Text(
                              toBeginningOfSentenceCase(subjectName!),
                              maxLines: 1,
                              style: title.upTextStyle.copyWith(fontSize: 24, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        AnimatedTextOverFlow(
                          child: Text(
                            toBeginningOfSentenceCase(data.description),
                            maxLines: 1,
                            style: title.upTextStyle.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                        Text(
                          data.gradeValue.toString(),
                          style: title.downTextStyle.copyWith(fontSize: 24, color: _getGradeColor(data, Theme.of(context))),
                        ),
                        Text(
                          "${data.percentageOfFinalGrade}%",
                          style: title.upTextStyle.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                        )
                      ],
                    ),
                  ),
                  if (onDeleteCallback != null)
                    Tooltip(
                      message: context.localizations.deleteGrade,
                      child: IconButton(
                        onPressed: onDeleteCallback,
                        icon: Icon(Icons.delete_forever_rounded),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(Grade grade, ThemeData theme) {
    return switch (double.tryParse(grade.gradeValue) ?? 4) {
      < 3 => theme.colorScheme.error,
      >= 4 => theme.colorScheme.primary,
      _ => theme.colorScheme.onSurfaceVariant,
    };
  }
}
