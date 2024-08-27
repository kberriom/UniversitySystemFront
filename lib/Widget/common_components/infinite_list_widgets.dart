import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Model/uni_system_model.dart';

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

///Creates a [SliverFixedExtentList] that displays the [currentStateList] fetched from a provider.
///
/// Every item in [currentStateList] be [UniSystemModel] or [null] represents a valid item at that [currentStateList] index.
///
/// Multiple underlying data caches might exist (search terms, filters).
/// For every item a SelfAwareListItem provider is created that loads the appropriate data for said index.
///
/// If a item in [currentStateList] is already a UniSystemModel instance and not null then is displayed as is.
class SelfAwareDataListSliver<T extends UniSystemModel, P extends ListItemPackage<UniSystemModel>> extends ConsumerWidget {
  final List<T?> currentStateList;
  final FixedExtentItemConstraints itemConstraints;
  final Future<P> Function(int index) selfAwareItemFuture;
  final Widget Function(T data, FixedExtentItemConstraints itemConstraints) itemWidget;
  final Widget Function(FixedExtentItemConstraints itemConstraints) loadingShimmerItem;
  final Widget Function(FixedExtentItemConstraints itemConstraints) errorItem;

  const SelfAwareDataListSliver(
      {required this.selfAwareItemFuture,
      required this.loadingShimmerItem,
      required this.itemWidget,
      required this.errorItem,
      required this.currentStateList,
      required this.itemConstraints,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          childCount: currentStateList.length,
          findChildIndexCallback: (key) {
            final idKey = (key as ValueKey<int>).value;
            final index = currentStateList.indexWhere((element) {
              if (element == null) {
                return false;
              }
              return element.id == idKey;
            });
            return index == -1 ? null : index;
          },
          (context, index) {
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
                      T data = currentStateList[index] ?? (snapshot.data!.itemData! as T);
                      return itemWidget.call(data, itemConstraints);
                    } else {
                      //On item error
                      return errorItem.call(itemConstraints);
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

///Listens to a future that returns the initial [list] of items and displays an appropriate widget, given the current [snapshot.connectionState]
///
/// A SelfAwareItem is a abstract way of interpreting an item in a list that is either a [UniSystemModel] or null.
///
/// Where null indicates that at [list[index]] there is a valid [ListItemPackage] that contains the data for said [list[index]] given the current [providerFuture],
class FutureSelfAwareListBuilder<T extends UniSystemModel> extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
