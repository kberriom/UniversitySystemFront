import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Controller/users/admin_users_widget_controller.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';
import 'package:university_system_front/Widget/navigation/animated_status_bar_color.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/search/search_widgets.dart';

typedef UserSelectionCallback = void Function(User user, UserRole role);

class AdminUsersWidget extends ConsumerStatefulWidget {
  final bool filterByStudent;
  final bool filterByTeacher;

  const AdminUsersWidget({
    super.key,
    this.filterByStudent = true,
    this.filterByTeacher = true,
  });

  @override
  ConsumerState<AdminUsersWidget> createState() => _AdminUsersWidgetState();
}

class _AdminUsersWidgetState extends ConsumerState<AdminUsersWidget> with AnimationMixin {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final ScrollController scrollController;
  late final TextEditingController searchTextController;
  late final AnimationController animationController;
  late final FixedExtentItemConstraints fixedExtentItemConstraints;
  late bool filterByStudent;
  late bool filterByTeacher;

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
    filterByStudent = widget.filterByStudent;
    filterByTeacher = widget.filterByTeacher;
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
      onRefresh: () => _refreshProviders(),
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
                  //todo add new user
                },
              ),
              body: UniSystemBackgroundDecoration(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  slivers: [
                    if (!context.isWindows) const UniSystemSliverAppBar(),
                    PinnedHeaderSliver(
                      child: UniSystemFiltersSearchBar(
                          hintText: context.localizations.adminUserListSearchBoxHint,
                          filterRowWidgets: [
                            FilterChip(
                              label: Text(context.localizations.userTypeNameStudent(2)),
                              showCheckmark: filterByStudent,
                              selected: filterByStudent,
                              onSelected: (bool value) {
                                setState(() {
                                  if (filterByTeacher) {
                                    filterByStudent = !filterByStudent;
                                  } else {
                                    showLocalSnackBar(scaffoldMessengerKey, context.localizations.oneFilterActiveRuleError);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 16),
                            FilterChip(
                              label: Text(context.localizations.userTypeNameTeacher(2)),
                              showCheckmark: filterByTeacher,
                              selected: filterByTeacher,
                              onSelected: (bool value) {
                                setState(() {
                                  if (filterByStudent) {
                                    filterByTeacher = !filterByTeacher;
                                  } else {
                                    showLocalSnackBar(scaffoldMessengerKey, context.localizations.oneFilterActiveRuleError);
                                  }
                                });
                              },
                            ),
                          ],
                          onRefreshCallback: () => _refreshProviders(),
                          searchTextController: searchTextController),
                    ),
                    FutureSelfAwareListBuilder(
                      providerFuture: ref.watch(adminUsersWidgetControllerProvider
                          .call(filterByTeacher, filterByStudent, searchTextController.value.text, getAll: false)
                          .future),
                      onDataWidgetBuilderCallback: (list) {
                        return SelfAwareDataListSliver(
                          maxCrossAxisCount: getCrossAxisCountForList(list),
                          itemConstraints: fixedExtentItemConstraints,
                          list: list,
                          selfAwareItemFuture: (index) =>
                              ref.watch(selfAwareUserListItemProvider.call(index, filterByTeacher, filterByStudent).future),
                          loadingShimmerItem: (itemConstraints) => LoadingShimmerItem(itemConstraints: itemConstraints),
                          errorItem: (itemConstraints) => GenericErrorItem(itemConstraints: itemConstraints),
                          itemWidget: (data, itemConstraints) {
                            return UserListItem(
                              data: data,
                              itemConstraints: itemConstraints,
                            );
                          },
                        );
                      },
                      loadingWidget: GenericSliverLoadingShimmer(fixedExtentItemConstraints: fixedExtentItemConstraints),
                      errorWidget: GenericSliverWarning(errorMessage: context.localizations.verboseError),
                      noDataWidget: GenericSliverWarning(errorMessage: context.localizations.adminUserListFetchNoData),
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

  Future<List<Object>> _refreshProviders() {
    return Future.wait([
      ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.student).future),
      ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.teacher).future),
    ]);
  }
}

class AdminForResultUserWidget extends ConsumerStatefulWidget {
  final UserSelectionCallback forResultCallback;
  final bool filterByStudent;
  final bool filterByTeacher;
  final bool enableFilters;

  const AdminForResultUserWidget({
    super.key,
    required this.forResultCallback,
    this.filterByStudent = true,
    this.filterByTeacher = true,
    this.enableFilters = false,
  });

  @override
  ConsumerState<AdminForResultUserWidget> createState() => _AdminForResultUserWidgetState();
}

class _AdminForResultUserWidgetState extends ConsumerState<AdminForResultUserWidget> with AnimationMixin {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final TextEditingController searchTextController;
  late final AnimationController animationController;
  late final FixedExtentItemConstraints fixedExtentItemConstraints;
  late bool filterByStudent;
  late bool filterByTeacher;

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
    filterByStudent = widget.filterByStudent;
    filterByTeacher = widget.filterByTeacher;
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshProviders(),
      edgeOffset: 70,
      displacement: 5,
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: UniSystemBackgroundDecoration(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                PinnedHeaderSliver(
                  child: UniSystemFiltersSearchBar(
                      hintText: context.localizations.adminUserListSearchBoxHint,
                      filterRowWidgets: [
                        FilterChip(
                          label: Text(context.localizations.userTypeNameStudent(2)),
                          showCheckmark: filterByStudent,
                          selected: filterByStudent,
                          onSelected: widget.enableFilters && widget.filterByStudent
                              ? (bool value) {
                                  setState(() {
                                    if (filterByTeacher) {
                                      filterByStudent = !filterByStudent;
                                    } else {
                                      showLocalSnackBar(scaffoldMessengerKey, context.localizations.oneFilterActiveRuleError);
                                    }
                                  });
                                }
                              : null,
                        ),
                        const SizedBox(width: 16),
                        FilterChip(
                          label: Text(context.localizations.userTypeNameTeacher(2)),
                          showCheckmark: filterByTeacher,
                          selected: filterByTeacher,
                          onSelected: widget.enableFilters && widget.filterByTeacher
                              ? (bool value) {
                                  setState(() {
                                    if (filterByStudent) {
                                      filterByTeacher = !filterByTeacher;
                                    } else {
                                      showLocalSnackBar(scaffoldMessengerKey, context.localizations.oneFilterActiveRuleError);
                                    }
                                  });
                                }
                              : null,
                        ),
                      ],
                      onRefreshCallback: () => _refreshProviders(),
                      searchTextController: searchTextController),
                ),
                FutureSelfAwareListBuilder(
                  providerFuture: ref.watch(adminUsersWidgetControllerProvider
                      .call(filterByTeacher, filterByStudent, searchTextController.value.text, getAll: true)
                      .future),
                  onDataWidgetBuilderCallback: (list) {
                    return SelfAwareDataListSliver(
                      maxCrossAxisCount: getCrossAxisCountForList(list),
                      itemConstraints: fixedExtentItemConstraints,
                      list: list,
                      selfAwareItemFuture: (index) =>
                          ref.watch(selfAwareUserListItemProvider.call(index, filterByTeacher, filterByStudent).future),
                      loadingShimmerItem: (itemConstraints) => LoadingShimmerItem(itemConstraints: itemConstraints),
                      errorItem: (itemConstraints) => GenericErrorItem(itemConstraints: itemConstraints),
                      itemWidget: (data, itemConstraints) {
                        return UserListItem(
                          data: data,
                          userSelectionCallback: widget.forResultCallback,
                          itemConstraints: itemConstraints,
                        );
                      },
                    );
                  },
                  loadingWidget: GenericSliverLoadingShimmer(fixedExtentItemConstraints: fixedExtentItemConstraints),
                  errorWidget: GenericSliverWarning(errorMessage: context.localizations.verboseError),
                  noDataWidget: GenericSliverWarning(errorMessage: context.localizations.adminUserListFetchNoData),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Object>> _refreshProviders() {
    return Future.wait([
      if (filterByTeacher) ref.refresh(fullUserListProvider.call(UserRole.teacher).future),
      if (filterByStudent) ref.refresh(fullUserListProvider.call(UserRole.student).future),
      ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.student).future),
      ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.teacher).future),
    ]);
  }
}

class UserListItem extends StatelessWidget {
  const UserListItem({
    super.key,
    required this.data,
    required this.itemConstraints,
    this.userSelectionCallback,
  });

  final User data;
  final UserSelectionCallback? userSelectionCallback;
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
              if (userSelectionCallback != null) {
                if (data is Student) {
                  userSelectionCallback!(data, UserRole.student);
                } else if (data is Teacher) {
                  userSelectionCallback!(data, UserRole.teacher);
                }
              }
              //TODO Detail view
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text("${data.name} ${data.lastName}", overflow: TextOverflow.ellipsis),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Tooltip(message: context.localizations.idTooltip, child: const Icon(Icons.badge_outlined)),
                            Text(" ${data.id}", overflow: TextOverflow.ellipsis),
                            const SizedBox(width: 5),
                            Tooltip(message: context.localizations.usernameTooltip, child: const Icon(Icons.account_circle)),
                            Text(" ${data.username}", overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (data.role == UserRole.student.roleName) ...[
                      const Icon(Icons.school),
                      Text(context.localizations.userTypeNameStudent(1)),
                    ],
                    if (data.role == UserRole.teacher.roleName) ...[
                      const Icon(Icons.hail),
                      Text(context.localizations.userTypeNameTeacher(1)),
                    ],
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
