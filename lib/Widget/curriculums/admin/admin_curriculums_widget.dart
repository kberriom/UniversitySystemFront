import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Controller/curriculum/admin_curriculum_widget_controller.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/curriculums/curriculum_list_item_widget.dart';
import 'package:university_system_front/Widget/navigation/animated_status_bar_color.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/search/search_widgets.dart';

class AdminCurriculumsWidget extends ConsumerStatefulWidget {
  const AdminCurriculumsWidget({super.key});

  @override
  ConsumerState<AdminCurriculumsWidget> createState() => _AdminCurriculumsWidgetState();
}

class _AdminCurriculumsWidgetState extends ConsumerState<AdminCurriculumsWidget> with AnimationMixin {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final ScrollController scrollController;
  late final TextEditingController searchTextController;
  late final AnimationController animationController;
  late final FixedExtentItemConstraints fixedExtentItemConstraints;

  int searchRequestKeyStrokeNumber = 0;

  @override
  void initState() {
    searchTextController = TextEditingController();
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
                  GoRouter.of(context).goNamed(GoRouterRoutes.adminAddCurriculum.routeName);
                },
              ),
              body: UniSystemBackgroundDecoration(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  slivers: [
                    if (!context.isWindows) const UniSystemSliverAppBar(),
                    PinnedHeaderSliver(
                      child: UniSystemSearchBar(
                          hintText: context.localizations.adminCurriculumSearchBoxHint,
                          onRefreshCallback: () => ref.refresh(paginatedCurriculumInfiniteListProvider.future),
                          searchTextController: searchTextController),
                    ),
                    FutureSelfAwareListBuilder(
                      providerFuture:
                          ref.watch(adminSubjectsWidgetControllerProvider.call(searchTextController.value.text).future),
                      onDataWidgetBuilderCallback: (list) {
                        return SelfAwareDataListSliver(
                          maxCrossAxisCount: getCrossAxisCountForList(list),
                          itemConstraints: fixedExtentItemConstraints,
                          list: list,
                          selfAwareItemFuture: (index) => ref.watch(selfAwareCurriculumListItemProvider.call(index).future),
                          loadingShimmerItem: (itemConstraints) => LoadingShimmerItem(itemConstraints: itemConstraints),
                          errorItem: (itemConstraints) => GenericErrorItem(itemConstraints: itemConstraints),
                          itemWidget: (data, itemConstraints) => CurriculumListItem(data: data, itemConstraints: itemConstraints),
                        );
                      },
                      loadingWidget: GenericSliverLoadingShimmer(fixedExtentItemConstraints: fixedExtentItemConstraints),
                      errorWidget: GenericSliverWarning(errorMessage: context.localizations.verboseError),
                      noDataWidget: GenericSliverWarning(errorMessage: context.localizations.adminCurriculumListFetchNoData),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
