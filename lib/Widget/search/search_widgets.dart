import 'package:flutter/material.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';

class UniSystemSearchBar extends StatefulWidget {
  final String hintText;
  final Future<void> Function() onRefreshCallback;
  final TextEditingController searchTextController;

  const UniSystemSearchBar({
    super.key,
    required this.hintText,
    required this.onRefreshCallback,
    required this.searchTextController,
  });

  @override
  State<UniSystemSearchBar> createState() => _UniSystemSearchBarState();
}

class _UniSystemSearchBarState extends State<UniSystemSearchBar> {
  int _searchRequestKeyStrokeNumber = 0;
  final TextEditingController _editingController = TextEditingController();

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: Durations.short2,
      child: Container(
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
                        onPressed: () => widget.onRefreshCallback.call(),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Flexible(
                      child: SearchAnchor(
                        builder: (context, controller) {
                          return SearchBar(
                            key: ValueKey(widget.hintText),
                            controller: _editingController,
                            onChanged: (value) async {
                              int thisRequestNumber = (_searchRequestKeyStrokeNumber += 1);
                              await Future.delayed(const Duration(milliseconds: 450));
                              if ((thisRequestNumber == _searchRequestKeyStrokeNumber) && mounted) {
                                widget.searchTextController.text = value;
                              }
                            },
                            onSubmitted: (value) {
                              widget.searchTextController.text = value;
                            },
                            hintText: widget.hintText,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            trailing: [
                              if (widget.searchTextController.value.text.isEmpty)
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
                              if (widget.searchTextController.value.text.isNotEmpty)
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          _editingController.clear();
                                          widget.searchTextController.clear();
                                        },
                                      ),
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
      ),
    );
  }
}

class UniSystemFiltersSearchBar extends StatefulWidget {
  final String hintText;
  final Future<void> Function() onRefreshCallback;
  final List<Widget> filterRowWidgets;
  final TextEditingController searchTextController;

  const UniSystemFiltersSearchBar({
    super.key,
    required this.hintText,
    required this.filterRowWidgets,
    required this.onRefreshCallback,
    required this.searchTextController,
  });

  @override
  State<UniSystemFiltersSearchBar> createState() => _UniSystemFiltersSearchBarState();
}

class _UniSystemFiltersSearchBarState extends State<UniSystemFiltersSearchBar> {
  bool _showFilters = false;
  int _searchRequestKeyStrokeNumber = 0;
  final TextEditingController _editingController = TextEditingController();

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: Durations.short2,
      child: Material(
        //Shadow if filters are being shown
        elevation: _showFilters ? 3 : 0,
        child: Container(
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
                          onPressed: () => widget.onRefreshCallback.call(),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Flexible(
                        child: SearchAnchor(
                          builder: (context, controller) {
                            return SearchBar(
                              controller: _editingController,
                              onChanged: (value) async {
                                int thisRequestNumber = (_searchRequestKeyStrokeNumber += 1);
                                await Future.delayed(const Duration(milliseconds: 450));
                                if ((thisRequestNumber == _searchRequestKeyStrokeNumber) && mounted) {
                                  widget.searchTextController.text = value;
                                }
                              },
                              onSubmitted: (value) {
                                widget.searchTextController.text = value;
                              },
                              hintText: widget.hintText,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              leading: Tooltip(
                                message: context.localizations.listFiltersTooltip,
                                child: IconButton(
                                    icon: const Icon(Icons.settings),
                                    onPressed: () {
                                      setState(() {
                                        _showFilters = !_showFilters;
                                      });
                                    }),
                              ),
                              trailing: [
                                if (widget.searchTextController.value.text.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 13),
                                    child: Icon(Icons.search),
                                  ),
                                if (widget.searchTextController.value.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        _editingController.clear();
                                        widget.searchTextController.clear();
                                      },
                                    ),
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
                if (_showFilters)
                  ConstrainedBox(
                    constraints: Theme.of(context).searchBarTheme.constraints!,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: widget.filterRowWidgets,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
