import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Controller/users/admin_users_widget_controller.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:university_system_front/Util/university_system_ui_localizations_helper.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';
import 'package:university_system_front/Widget/common_components/uni_system_appbars.dart';
import 'package:university_system_front/Widget/common_components/scaffold_background_decoration.dart';

class AdminUsersWidget extends ConsumerStatefulWidget {
  const AdminUsersWidget({super.key});

  @override
  ConsumerState<AdminUsersWidget> createState() => _AdminUsersWidgetState();
}

class _AdminUsersWidgetState extends ConsumerState<AdminUsersWidget> with AnimationMixin {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final SearchController searchController;
  late final ScrollController scrollController;
  late final TextEditingController searchTextController;
  late final AnimationController animationController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    searchController = SearchController();
    scrollController = ScrollController();
    animationController = createController(unbounded: true, fps: 60);
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

  final appBarHeight = const UniSystemSliverAppBar().preferredSize.height;
  final double userItemHeight = 80;
  final double userItemMinWidth = 300;
  final double userItemMaxWidth = 800;
  Color? animatedStatusBarColor;

  bool showFilters = false;
  bool filterByStudent = true;
  bool filterByTeacher = true;

  int searchRequestKeyStrokeNumber = 0;

  @override
  Widget build(BuildContext context) {
    //Set the status bar color depending on scroll extent to create seamless appbar/searchBar
    setScrollExtentStatusBarColorListener(context);

    return RefreshIndicator(
      onRefresh: () {
        final refreshFuture = Future.wait([
          ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.student).future),
          ref.refresh(paginatedUserInfiniteListProvider.call(UserRole.teacher).future),
        ]);
        return refreshFuture;
      },
      edgeOffset: 150,
      displacement: 10,
      child: AnimatedContainer(
        color: animatedStatusBarColor ?? Theme.of(context).colorScheme.surfaceBright,
        duration: Durations.short1,
        child: SafeArea(
          bottom: false,
          child: ScaffoldMessenger(
            key: scaffoldMessengerKey,
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: ScaffoldBackgroundDecoration(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      if (!Platform.isWindows) const UniSystemSliverAppBar(),
                      PinnedHeaderSliver(
                        child: AnimatedSize(
                          alignment: Alignment.topCenter,
                          duration: Durations.short2,
                          child: buildSearchBar(context),
                        ),
                      ),
                      UserListFutureBuilder(
                        filterByTeacher,
                        filterByStudent,
                        animationController: animationController,
                        cardHeight: userItemHeight,
                        cardMinWidthConstraints: userItemMinWidth,
                        cardMaxWidthConstraints: userItemMaxWidth,
                        providerFuture: ref.watch(adminUsersWidgetControllerProvider
                            .call(filterByTeacher, filterByStudent, searchController.value.text)
                            .future),
                        loadingWidget: SliverFillRemaining(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                            child: FixedExtentShimmerList(
                              animationController: animationController,
                              itemExtent: userItemHeight,
                              itemsPadding: 16,
                              itemMinWidth: userItemMinWidth,
                              itemMaxWidth: userItemMaxWidth,
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
                              Text(context.localizations.adminUserListFetchNoData),
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

  void setScrollExtentStatusBarColorListener(BuildContext context) {
    if (!scrollController.hasClients && !Platform.isWindows) {
      //Only on the first frame build does scrollController not have any clients
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        scrollController.addListener(() {
          if (scrollController.position.pixels > appBarHeight) {
            setState(() {
              animatedStatusBarColor = Theme.of(context).colorScheme.surfaceContainerLow;
            });
          } else if (scrollController.position.pixels <= appBarHeight) {
            setState(() {
              animatedStatusBarColor = Theme.of(context).colorScheme.surfaceBright;
            });
          }
        });
      });
    }
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
                    if (Platform.isWindows) ...[
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
                              if (value.isEmpty) {
                                searchController.text = value;
                                return;
                              }
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
              onSelected: (bool value) {
                setState(() {
                  if (filterByTeacher) {
                    filterByStudent = !filterByStudent;
                  } else {
                    _showErrorOneFilterReq(context);
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
                    _showErrorOneFilterReq(context);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorOneFilterReq(BuildContext context) {
    scaffoldMessengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(context.localizations.oneFilterActiveRuleError)));
  }
}

class UserListSliver extends ConsumerWidget {
  ///Must be ordered students then teachers
  final List<User?> list;
  final bool showTeacherList;
  final bool showStudentList;
  final double cardHeight;
  final double cardMinWidthConstraints;
  final double cardMaxWidthConstraints;
  final AnimationController animationController;

  const UserListSliver(this.showTeacherList, this.showStudentList,
      {required this.list,
      required this.cardHeight,
      required this.cardMinWidthConstraints,
      required this.cardMaxWidthConstraints,
      required this.animationController,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          childCount: list.length,
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
            return FutureBuilder(
              future: ref.watch(selfAwareUserListItemProvider.call(index, showTeacherList, showStudentList).future),
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
                            animationController: animationController,
                            itemCount: 1,
                            itemMaxWidth: cardMaxWidthConstraints,
                            itemMinWidth: cardMinWidthConstraints,
                            itemExtent: cardHeight,
                            itemsPadding: 0),
                      ),
                    );
                  case ConnectionState.done:
                    if (snapshot.data != null && snapshot.data!.userData != null) {
                      User data = list[index] ?? snapshot.data!.userData!;
                      return Padding(
                        key: ValueKey<int>(data.id),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: cardMinWidthConstraints,
                                maxWidth: cardMaxWidthConstraints,
                                minHeight: cardHeight,
                                maxHeight: cardHeight),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                          child: Text("${data.name} ${data.lastName}", overflow: TextOverflow.ellipsis),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Text(data.username, overflow: TextOverflow.ellipsis),
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
                    } else {
                      //On item error
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: cardMinWidthConstraints,
                                maxWidth: cardMaxWidthConstraints,
                                minHeight: cardHeight,
                                maxHeight: cardHeight),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                                overlayColor: Colors.transparent,
                                enableFeedback: false,
                                enabledMouseCursor: MouseCursor.defer,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              },
            );
          },
        ),
        //cardHeight + (vertical padding) of each item so the content is really (cardHeight) and not a implicit (cardHeight - padding)
        itemExtent: cardHeight + 16,
      ),
    );
  }
}

class UserListFutureBuilder extends ConsumerWidget {
  final Future<List<User?>> providerFuture;
  final bool showTeacherList;
  final bool showStudentList;
  final Widget loadingWidget;
  final Widget errorWidget;
  final Widget noDataWidget;
  final double cardHeight;
  final double cardMinWidthConstraints;
  final double cardMaxWidthConstraints;
  final AnimationController animationController;

  const UserListFutureBuilder(
    this.showTeacherList,
    this.showStudentList, {
    super.key,
    required this.animationController,
    required this.cardHeight,
    required this.providerFuture,
    required this.loadingWidget,
    required this.errorWidget,
    required this.noDataWidget,
    required this.cardMinWidthConstraints,
    required this.cardMaxWidthConstraints,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: providerFuture,
      builder: (BuildContext context, AsyncSnapshot<List<User?>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (!snapshot.hasData && snapshot.hasError) {
              return errorWidget;
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return noDataWidget;
            } else {
              return UserListSliver(
                showTeacherList,
                showStudentList,
                list: snapshot.data!,
                cardHeight: cardHeight,
                cardMaxWidthConstraints: cardMaxWidthConstraints,
                cardMinWidthConstraints: cardMinWidthConstraints,
                animationController: animationController,
              );
            }
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return loadingWidget;
        }
      },
    );
  }
}
