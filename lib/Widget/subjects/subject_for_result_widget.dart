import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Service/search_service.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/search/search_widgets.dart';
import 'package:university_system_front/Widget/subjects/subject_list_item_widget.dart';

class SubjectForResultWidget extends ConsumerStatefulWidget {
  final void Function(Subject subject) onResultCallback;
  final Future<List<Subject>> Function() listCallback;
  final Future<List<Subject>> Function()? excludeListCallback;
  final Future<void> Function()? onRefreshCallback;
  final bool showSearchBar;

  const SubjectForResultWidget({
    super.key,
    required this.listCallback,
    this.onRefreshCallback,
    required this.onResultCallback,
    this.excludeListCallback,
    this.showSearchBar = false,
  });

  @override
  ConsumerState<SubjectForResultWidget> createState() => _SubjectForResultWidgetState();
}

class _SubjectForResultWidgetState extends ConsumerState<SubjectForResultWidget> with AnimationMixin {
  late final TextEditingController searchTextController;
  late final AnimationController animationController;
  late final FixedExtentItemConstraints fixedExtentItemConstraints;

  late SearchService<Subject> subjectSearchService;
  late Future<List<Subject>> listFuture;

  @override
  void initState() {
    searchTextController = TextEditingController();
    animationController = createController(unbounded: true, fps: 60);
    fixedExtentItemConstraints = FixedExtentItemConstraints(
      animationController: animationController,
      cardHeight: 80,
      cardMinWidthConstraints: 300,
      cardMaxWidthConstraints: 800,
    );
    refreshListFuture(search: "");
    searchTextController.addListener(() {
      setState(() {
        listFuture = subjectSearchService.findBySearchTerm(searchTextController.value.text);
      });
    });
    super.initState();
  }

  void refreshListFuture({required String search}) {
    subjectSearchService = SearchService.exclude(
      unfilteredList: widget.listCallback(),
      excludeList: (widget.excludeListCallback ?? () => Future.value(const <Subject>[]))(),
    );
    listFuture = subjectSearchService.findBySearchTerm(search);
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (!context.isWindows) const UniSystemSliverAppBar(),
        if (widget.showSearchBar)
          PinnedHeaderSliver(
            child: UniSystemSearchBar(
              searchTextController: searchTextController,
              onRefreshCallback: () async {
                setState(() {
                  refreshListFuture(search: searchTextController.value.text);
                });
                if (widget.onRefreshCallback != null) {
                  widget.onRefreshCallback!();
                }
              },
              hintText: context.localizations.adminSubjectSearchBoxHint,
            ),
          ),
        FutureListBuilder(
          providerFuture: listFuture,
          onDataWidgetBuilderCallback: (list) {
            int crossAxisCount = 1;
            if (list.length.isEven) {
              crossAxisCount = 2;
            } else if (list.length >= 3) {
              crossAxisCount = 3;
            }
            return SliverFillRemaining(
              child: ListLayoutBuilder(
                maxCrossAxisCount: crossAxisCount,
                noMoreItemsWidget: const SizedBox.expand(),
                itemConstraints: fixedExtentItemConstraints,
                list: list,
                itemWidget: (data, itemConstraints) => SubjectListItem(
                    key: ValueKey(data),
                    data: data,
                    itemConstraints: itemConstraints,
                    onPressedCallback: widget.onResultCallback),
              ),
            );
          },
          loadingWidget: GenericSliverLoadingShimmer(fixedExtentItemConstraints: fixedExtentItemConstraints),
          errorWidget: GenericSliverWarning(errorMessage: context.localizations.verboseError),
          noDataWidget: GenericSliverWarning(errorMessage: context.localizations.adminSubjectListFetchNoData),
        ),
      ],
    );
  }
}
