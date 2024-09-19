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
import 'package:university_system_front/Widget/common_components/scaffold_background_decoration.dart';

typedef UserSelectionCallback = void Function(User user, UserRole role);

class AdminUsersWidget extends ConsumerStatefulWidget {
  final UserSelectionCallback? forResultCallback;
  final bool filterByStudent;
  final bool filterByTeacher;

  const AdminUsersWidget({
    super.key,
    this.forResultCallback,
    this.filterByStudent = true,
    this.filterByTeacher = true,
  });

  @override
  ConsumerState<AdminUsersWidget> createState() => _AdminUsersWidgetState();
}

class _AdminUsersWidgetState extends ConsumerState<AdminUsersWidget> with AnimationMixin {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final SearchController searchController;
  late final ScrollController scrollController;
  late final TextEditingController searchTextController;
  late final AnimationController animationController;
  late final FixedExtentItemConstraints fixedExtentItemConstraints;
  late bool filterByStudent;
  late bool filterByTeacher;

  int searchRequestKeyStrokeNumber = 0;
  bool showFilters = false;

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
    filterByStudent = widget.filterByStudent;
    filterByTeacher = widget.filterByTeacher;
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchTextController.dispose();
    scrollController.removeListener(() {});
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        final refreshFuture = Future.wait([
          if (widget.forResultCallback != null && filterByTeacher)
            ref.refresh(fullUserListProvider.call(UserRole.teacher).future),
          if (widget.forResultCallback != null && filterByStudent)
            ref.refresh(fullUserListProvider.call(UserRole.student).future),
          ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.student).future),
          ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.teacher).future),
        ]).then(
          (value) => setState(() {}),
        );
        return refreshFuture;
      },
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
              floatingActionButton: widget.forResultCallback == null
                  ? FloatingActionButton(
                      child: const Icon(Icons.add),
                      onPressed: () {
                        //todo add new user
                      },
                    )
                  : null,
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
                      providerFuture: ref.watch(adminUsersWidgetControllerProvider
                          .call(filterByTeacher, filterByStudent, searchController.value.text,
                              getAll: widget.forResultCallback != null)
                          .future),
                      onDataWidgetBuilderCallback: (list) {
                        return UserListSliver(
                          filterByTeacher: filterByTeacher,
                          filterByStudent: filterByStudent,
                          list: list,
                          itemConstraints: fixedExtentItemConstraints,
                          isComplete: list.last != null,
                          userSelectionCallback: widget.forResultCallback,
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

  Widget buildSearchBar(BuildContext context) {
    return Material(
      //Shadow if buildFiltersRow is being shown
      elevation: showFilters ? 3 : 0,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
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
                          onPressed: () => Future.wait([
                                ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.student).future),
                                ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.teacher).future),
                              ])),
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
                            hintText: context.localizations.adminUserListSearchBoxHint,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            leading: Tooltip(
                              message: context.localizations.adminUserListFiltersBoxTooltip,
                              child: IconButton(
                                  icon: const Icon(Icons.settings),
                                  onPressed: () {
                                    setState(() {
                                      showFilters = !showFilters;
                                    });
                                  }),
                            ),
                            trailing: [
                              if (searchController.value.text.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(right: 13),
                                  child: Icon(Icons.search),
                                ),
                              if (searchController.value.text.isNotEmpty)
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
              if (showFilters) buildFiltersRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFiltersRow(BuildContext context) {
    return ConstrainedBox(
      constraints: Theme.of(context).searchBarTheme.constraints!,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FilterChip(
              label: Text(context.localizations.userTypeNameStudent(2)),
              showCheckmark: filterByStudent,
              selected: filterByStudent,
              onSelected: widget.forResultCallback == null
                  ? (bool value) {
                      setState(() {
                        if (filterByTeacher) {
                          filterByStudent = !filterByStudent;
                        } else {
                          _showErrorOneFilterReq(context);
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
              onSelected: widget.forResultCallback == null
                  ? (bool value) {
                      setState(() {
                        if (filterByStudent) {
                          filterByTeacher = !filterByTeacher;
                        } else {
                          _showErrorOneFilterReq(context);
                        }
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorOneFilterReq(BuildContext context) {
    context.showLocalSnackBar(scaffoldMessengerKey, context.localizations.oneFilterActiveRuleError);
  }
}

class UserListSliver extends ConsumerWidget {
  ///Must be ordered students then teachers
  final List<User?> list;
  final bool isComplete;
  final UserSelectionCallback? userSelectionCallback;
  final bool filterByTeacher;
  final bool filterByStudent;
  final FixedExtentItemConstraints itemConstraints;
  final int _childCount;

  const UserListSliver({
    super.key,
    required this.filterByTeacher,
    required this.filterByStudent,
    required this.list,
    required this.isComplete,
    required this.itemConstraints,
    this.userSelectionCallback,
  }) : _childCount = list.length >= 6 ? list.length + 1 : list.length; //Show no more items if more than 7 items in list

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          childCount: _childCount,
          findChildIndexCallback: (key) {
            final idKey = (key as ValueKey<int>).value;
            final index = list.indexWhere((element) {
              if (element == null) {
                return false;
              }
              return element.id == idKey;
            });
            return index == -1 ? null : index;
          },
          (context, index) {
            if (index == list.length) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [const Icon(Icons.playlist_add_check), Text(context.localizations.noMoreItems)],
              );
            }
            if (isComplete) {
              return UserItem(
                data: list[index]!,
                userSelectionCallback: userSelectionCallback,
                itemConstraints: itemConstraints,
              );
            }
            return FutureBuilder(
              future: ref.watch(selfAwareUserListItemProvider.call(index, filterByTeacher, filterByStudent).future),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.center,
                        child: FixedExtentShimmerList(
                            animationController: itemConstraints.animationController,
                            itemCount: 1,
                            itemMaxWidth: itemConstraints.cardMaxWidthConstraints,
                            itemMinWidth: itemConstraints.cardMinWidthConstraints,
                            itemExtent: itemConstraints.cardHeight,
                            itemsPadding: 0),
                      ),
                    );
                  case ConnectionState.done:
                    if (snapshot.data != null && snapshot.data!.userData != null) {
                      User data = list[index] ?? snapshot.data!.userData!;
                      return UserItem(
                        data: data,
                        itemConstraints: itemConstraints,
                      );
                    } else {
                      return GenericErrorItem(itemConstraints: itemConstraints);
                    }
                }
              },
            );
          },
        ),
        //cardHeight + (vertical padding) of each item so the content is really (cardHeight) and not a implicit (cardHeight - padding)
        itemExtent: itemConstraints.cardHeight + 16,
      ),
    );
  }
}

class UserItem extends StatelessWidget {
  const UserItem({
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
