import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Controller/curriculum/admin_curriculum_widget_controller.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';
import 'package:university_system_front/Widget/common_components/scaffold_background_decoration.dart';
import 'package:university_system_front/Widget/navigation/animated_status_bar_color.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class AdminCurriculumsWidget extends ConsumerStatefulWidget {
  const AdminCurriculumsWidget({super.key});

  @override
  ConsumerState<AdminCurriculumsWidget> createState() => _AdminCurriculumsWidgetState();
}

class _AdminCurriculumsWidgetState extends ConsumerState<AdminCurriculumsWidget> with AnimationMixin {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final SearchController searchController;
  late final ScrollController scrollController;
  late final TextEditingController searchTextController;
  late final AnimationController animationController;
  late final FixedExtentItemConstraints fixedExtentItemConstraints;

  int searchRequestKeyStrokeNumber = 0;

  @override
  void initState() {
    searchTextController = TextEditingController();
    searchController = SearchController();
    scrollController = ScrollController();
    animationController = createController(unbounded: true, fps: 60);
    fixedExtentItemConstraints = FixedExtentItemConstraints(
      animationController: animationController,
      cardHeight: 80,
      cardMinWidthConstraints: 300,
      cardMaxWidthConstraints: 800,
    );
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchTextController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(paginatedCurriculumInfiniteListProvider.future),
      edgeOffset: 150,
      displacement: 10,
      child: AnimatedStatusBarColor(
        scrollController: scrollController,
        child: SafeArea(
          bottom: false,
          child: ScaffoldMessenger(
            key: scaffoldMessengerKey,
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    //TODO add new Curriculum
                  },
                ),
                body: ScaffoldBackgroundDecoration(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    slivers: [
                      if (!context.isWindows) const UniSystemSliverAppBar(),
                      PinnedHeaderSliver(
                        child: AnimatedSize(
                          alignment: Alignment.topCenter,
                          duration: Durations.short2,
                          child: buildSearchBar(context),
                        ),
                      ),
                      FutureSelfAwareListBuilder(
                        onDataWidgetBuilderCallback: (list) {
                          return SelfAwareDataListSliver(
                            itemConstraints: fixedExtentItemConstraints,
                            currentStateList: list,
                            selfAwareItemFuture: (index) => ref.watch(selfAwareCurriculumListItemProvider.call(index).future),
                            loadingShimmerItem: (itemConstraints) => LoadingShimmerItem(itemConstraints: itemConstraints),
                            errorItem: (itemConstraints) => CurriculumErrorItem(itemConstraints: itemConstraints),
                            itemWidget: (data, itemConstraints) => CurriculumItem(data: data, itemConstraints: itemConstraints),
                          );
                        },
                        providerFuture: ref.watch(adminSubjectsWidgetControllerProvider.call(searchController.value.text).future),
                        loadingWidget: SliverFillRemaining(
                          child: Padding(
                            padding: const EdgeInsets.only(left: kBodyHorizontalPadding, right: kBodyHorizontalPadding, top: 10),
                            child: FixedExtentShimmerList(
                              animationController: animationController,
                              itemExtent: fixedExtentItemConstraints.cardHeight,
                              itemsPadding: 16,
                              itemMinWidth: fixedExtentItemConstraints.cardMinWidthConstraints,
                              itemMaxWidth: fixedExtentItemConstraints.cardMaxWidthConstraints,
                            ),
                          ),
                        ),
                        errorWidget: SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Icon(Icons.error, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                              Text(context.localizations.verboseError),
                            ],
                          ),
                        ),
                        noDataWidget: SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Icon(Icons.info, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                              Text(context.localizations.adminCurriculumListFetchNoData),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.only(left: kBodyHorizontalPadding, right: kBodyHorizontalPadding, bottom: 8, top: 8),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: Theme.of(context).searchBarTheme.constraints!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (context.isWindows) ...[
                    //Windows has no pull to refresh, it needs a button
                    AnimatedRefreshButton(
                      onPressed: () => ref.refresh(paginatedCurriculumInfiniteListProvider.future),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Flexible(
                    child: SearchAnchor(
                      searchController: searchController,
                      builder: (context, controller) {
                        return SearchBar(
                          controller: searchTextController,
                          onChanged: (value) async {
                            int thisRequestNumber = (searchRequestKeyStrokeNumber += 1);
                            await Future.delayed(const Duration(milliseconds: 450));
                            if ((thisRequestNumber == searchRequestKeyStrokeNumber) && mounted) {
                              searchController.text = value;
                            }
                          },
                          onSubmitted: (value) {
                            searchController.text = value;
                          },
                          hintText: context.localizations.adminCurriculumSearchBoxHint,
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          trailing: [
                            if (searchController.value.text.isEmpty)
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Visibility(
                                      maintainSize: true,
                                      visible: false,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      child: IconButton(icon: const Icon(Icons.settings), onPressed: () {})),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Center(child: Icon(Icons.search)),
                                  ),
                                ],
                              ),
                            if (searchController.value.text.isNotEmpty)
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            searchTextController.clear();
                                            searchController.clear();
                                          });
                                        }),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                      suggestionsBuilder: (BuildContext context, SearchController controller) {
                        return [];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurriculumErrorItem extends StatelessWidget {
  const CurriculumErrorItem({
    super.key,
    required this.itemConstraints,
  });

  final FixedExtentItemConstraints itemConstraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              splashFactory: NoSplash.splashFactory,
              overlayColor: Colors.transparent,
              enableFeedback: false,
              enabledMouseCursor: MouseCursor.defer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () {},
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  Text(
                    context.localizations.error,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CurriculumItem extends StatelessWidget {
  const CurriculumItem({
    super.key,
    required this.data,
    required this.itemConstraints,
  });

  final Curriculum data;
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
            onPressed: () {}, //TODO Detail view
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
                        child: Text('${data.dateStart} — ${data.dateEnd}', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.library_books_rounded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
