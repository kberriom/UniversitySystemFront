import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Service/search_service.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/search/search_widgets.dart';
import 'package:university_system_front/Widget/subjects/subject_list_item_widget.dart';

class SubjectForResultWidget extends ConsumerStatefulWidget {
  final void Function(Subject subject) onResultCallback;
  final Future<List<Subject>> Function() listCallback;
  final Future<List<Subject>> Function()? excludeListCallback;
  final bool showSearchBar;

  const SubjectForResultWidget({
    super.key,
    required this.listCallback,
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

  Future refreshListFuture({required String search, bool callSetState = false}) {
    subjectSearchService = SearchService.exclude(
      unfilteredList: widget.listCallback(),
      excludeList: (widget.excludeListCallback ?? () => Future.value(const <Subject>[]))(),
    );
    if (callSetState) {
      setState(() {
        listFuture = subjectSearchService.findBySearchTerm(search);
      });
    } else {
      listFuture = subjectSearchService.findBySearchTerm(search);
    }
    return listFuture;
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      edgeOffset: widget.showSearchBar ? 70 : 0,
      displacement: 5,
      onRefresh: () => refreshListFuture(search: searchTextController.value.text, callSetState: true),
      child: CustomScrollView(
        slivers: [
          if (widget.showSearchBar)
            PinnedHeaderSliver(
              child: UniSystemSearchBar(
                searchTextController: searchTextController,
                onRefreshCallback: () async {
                  setState(() {
                    refreshListFuture(search: searchTextController.value.text);
                  });
                },
                hintText: context.localizations.adminSubjectSearchBoxHint,
              ),
            ),
          FutureListBuilder(
            listFuture: listFuture,
            onDataWidgetBuilderCallback: (list) {
              return ListLayoutBuilder(
                maxCrossAxisCount: getCrossAxisCountForList(list),
                itemConstraints: fixedExtentItemConstraints,
                list: list,
                itemWidget: (data, itemConstraints) => SubjectListItem(
                    key: ValueKey<Subject>(data),
                    data: data,
                    itemConstraints: itemConstraints,
                    onPressedCallback: widget.onResultCallback),
              );
            },
            loadingWidget: GenericSliverLoadingShimmer(fixedExtentItemConstraints: fixedExtentItemConstraints),
            errorWidget: GenericSliverWarning(errorMessage: context.localizations.verboseError),
            noDataWidget: GenericSliverWarning(errorMessage: context.localizations.adminSubjectListFetchNoData),
          ),
        ],
      ),
    );
  }
}
