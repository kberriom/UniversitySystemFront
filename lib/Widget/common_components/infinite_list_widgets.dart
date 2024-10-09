import 'package:flutter/material.dart';
import 'package:university_system_front/Model/uni_system_model.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';

final class FixedExtentItemConstraints {
  final double cardHeight;
  final double cardMinWidthConstraints;
  final double cardMaxWidthConstraints;

  ///Synchronises all animations to a single [AnimationController]
  ///Useful for syncing shimmer animations on a [SliverFixedExtentList]
  final AnimationController animationController;

  const FixedExtentItemConstraints({
    required this.cardHeight,
    required this.cardMinWidthConstraints,
    required this.cardMaxWidthConstraints,
    required this.animationController,
  });
}

class GenericErrorItem extends StatelessWidget {
  const GenericErrorItem({
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

class GenericSliverLoadingShimmer extends StatelessWidget {
  const GenericSliverLoadingShimmer({
    super.key,
    required this.fixedExtentItemConstraints,
  });

  final FixedExtentItemConstraints fixedExtentItemConstraints;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.only(left: kBodyHorizontalPadding, right: kBodyHorizontalPadding, top: 10),
        child: FixedExtentShimmerList(
          animationController: fixedExtentItemConstraints.animationController,
          itemExtent: fixedExtentItemConstraints.cardHeight,
          itemsPadding: 16,
          itemMinWidth: fixedExtentItemConstraints.cardMinWidthConstraints,
          itemMaxWidth: fixedExtentItemConstraints.cardMaxWidthConstraints,
        ),
      ),
    );
  }
}

class GenericSliverWarning extends StatelessWidget {
  final IconData icon;
  final String errorMessage;

  const GenericSliverWarning({
    super.key,
    required this.errorMessage,
    this.icon = Icons.error,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Icon(icon, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(errorMessage),
        ],
      ),
    );
  }
}

///Creates a [SliverGridDelegateWithFixedCrossAxisCount] that displays the [list] fetched from a provider.
///
/// Every item in [list] be [UniSystemModel] or [null] represents a valid item at that [list] index.
///
/// Multiple underlying data caches might exist (search terms, filters).
/// For every item a SelfAwareListItem provider is created that loads the appropriate data for said index.
///
/// If a item in [list] is already a UniSystemModel instance and not null then is displayed as is.
class SelfAwareDataListSliver<T extends UniSystemModel, P extends ListItemPackage<UniSystemModel>> extends StatelessWidget {
  final List<T?> list;
  final FixedExtentItemConstraints itemConstraints;
  final Future<P> Function(int index) selfAwareItemFuture;
  final Widget Function(T data, FixedExtentItemConstraints itemConstraints) itemWidget;
  final Widget Function(FixedExtentItemConstraints itemConstraints) loadingShimmerItem;
  final Widget Function(FixedExtentItemConstraints itemConstraints) errorItem;
  final int _childCount;
  final int maxCrossAxisCount;
  final double layoutDoubleBreakpoint;
  final double layoutTriBreakpoint;

  ///A widget to indicate that all items are shown,
  ///If null shows a empty box of [itemConstraints.cardHeight]
  final Widget? noMoreItemsWidget;

  const SelfAwareDataListSliver(
      {required this.selfAwareItemFuture,
      required this.loadingShimmerItem,
      required this.itemWidget,
      required this.errorItem,
      required this.list,
      required this.itemConstraints,
      double showNoMoreItemsMinLength = 6,
      this.noMoreItemsWidget,
      this.maxCrossAxisCount = 1,
      this.layoutTriBreakpoint = 1425,
      this.layoutDoubleBreakpoint = 950,
      super.key})
      : _childCount = list.length >= showNoMoreItemsMinLength ? list.length + 1 : list.length;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          late final int crossAxisCountPosible;
          if (list.length > 1) {
            if (constraints.crossAxisExtent >= layoutTriBreakpoint && maxCrossAxisCount >= 3) {
              crossAxisCountPosible = 3;
            } else if (constraints.crossAxisExtent >= layoutDoubleBreakpoint) {
              crossAxisCountPosible = maxCrossAxisCount >= 2 ? 2 : 1;
            } else {
              crossAxisCountPosible = 1;
            }
          } else {
            crossAxisCountPosible = 1;
          }
          return SliverGrid.builder(
            itemCount: _childCount,
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCountPosible, mainAxisExtent: itemConstraints.cardHeight + 16),
            itemBuilder: (BuildContext context, int index) {
              if (index == list.length) {
                return noMoreItemsWidget ?? const SizedBox.expand();
              }
              return FutureBuilder(
                future: selfAwareItemFuture.call(index),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return loadingShimmerItem(itemConstraints);
                    case ConnectionState.done:
                      if (snapshot.data != null && snapshot.data!.itemData != null) {
                        T data = list[index] ?? (snapshot.data!.itemData! as T);
                        return itemWidget.call(data, itemConstraints);
                      } else {
                        //On item error
                        return errorItem.call(itemConstraints);
                      }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

///Listens to a future that returns the initial [list] of items and displays an appropriate widget, given the current [snapshot.connectionState]
///
/// A SelfAwareItem is a abstract way of interpreting an item in a list that is either a [UniSystemModel] or null.
///
/// Where null indicates that at [list[index]] there is a valid [ListItemPackage] that contains the data for said [list[index]] given the current [providerFuture],
class FutureSelfAwareListBuilder<T extends UniSystemModel> extends StatelessWidget {
  final Future<List<T?>> providerFuture;
  final Widget Function(List<T?> list) onDataWidgetBuilderCallback;
  final Widget loadingWidget;
  final Widget errorWidget;
  final Widget noDataWidget;

  const FutureSelfAwareListBuilder({
    super.key,
    required this.onDataWidgetBuilderCallback,
    required this.providerFuture,
    required this.loadingWidget,
    required this.errorWidget,
    required this.noDataWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: providerFuture,
      builder: (BuildContext context, AsyncSnapshot<List<T?>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (!snapshot.hasData && snapshot.hasError) {
              return errorWidget;
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return noDataWidget;
            } else {
              return onDataWidgetBuilderCallback.call(snapshot.data!);
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

class ListLayoutBuilder<T extends UniSystemModel> extends StatelessWidget {
  final List<T> list;
  final FixedExtentItemConstraints itemConstraints;
  final int _childCount;
  final int maxCrossAxisCount;
  final double layoutDoubleBreakpoint;
  final double layoutTriBreakpoint;

  ///The returned Widget _must_ implement it's key as [ValueKey] of [data]
  final Widget Function(T data, FixedExtentItemConstraints itemConstraints) itemWidget;

  ///A widget to indicate that all items are shown,
  ///If null shows a icon with text.
  final Widget? noMoreItemsWidget;

  const ListLayoutBuilder({
    super.key,
    required this.itemWidget,
    required this.list,
    required this.itemConstraints,
    showNoMoreItemsMinLength = 3,
    this.noMoreItemsWidget,
    this.maxCrossAxisCount = 1,
    this.layoutTriBreakpoint = 1425,
    this.layoutDoubleBreakpoint = 950,
  }) : _childCount = list.length >= showNoMoreItemsMinLength ? list.length + 1 : list.length;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          late final int crossAxisCountPosible;
          if (list.length > 1) {
            if (constraints.crossAxisExtent >= layoutTriBreakpoint && maxCrossAxisCount >= 3) {
              crossAxisCountPosible = 3;
            } else if (constraints.crossAxisExtent >= layoutDoubleBreakpoint) {
              crossAxisCountPosible = maxCrossAxisCount >= 2 ? 2 : 1;
            } else {
              crossAxisCountPosible = 1;
            }
          } else {
            crossAxisCountPosible = 1;
          }
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCountPosible, mainAxisExtent: itemConstraints.cardHeight + 16),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == list.length) {
                  return noMoreItemsWidget ?? const SizedBox.expand();
                } else if (index > list.length) {
                  return null;
                }
                return itemWidget.call(list[index], itemConstraints);
              },
              childCount: _childCount,
              findChildIndexCallback: (key) {
                final keyValue = (key as ValueKey<T>).value;
                final index = list.indexOf(keyValue);
                return index == -1 ? null : index;
              },
            ),
          );
        },
      ),
    );
  }
}

class FutureListBuilder<T> extends StatelessWidget {
  final Future<List<T>> listFuture;
  final Widget Function(List<T> list) onDataWidgetBuilderCallback;
  final Widget loadingWidget;
  final Widget errorWidget;
  final Widget noDataWidget;

  const FutureListBuilder({
    super.key,
    required this.onDataWidgetBuilderCallback,
    required this.listFuture,
    required this.loadingWidget,
    required this.errorWidget,
    required this.noDataWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: listFuture,
      builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (!snapshot.hasData && snapshot.hasError) {
              return errorWidget;
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return noDataWidget;
            } else {
              return onDataWidgetBuilderCallback.call(snapshot.data!);
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

int getCrossAxisCountForList(List list) {
  int crossAxisCount = 1;
  if (list.length.isEven) {
    crossAxisCount = 2;
  } else if (list.length >= 3) {
    crossAxisCount = 3;
  }
  return crossAxisCount;
}
