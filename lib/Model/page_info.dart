import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/uni_system_model.dart';

part 'page_info.mapper.dart';

@MappableClass()
class PageInfo with PageInfoMappable {
  int currentPage;
  int currentPageSize;
  int maxPages;
  int maxItems;

  PageInfo(this.currentPage, this.currentPageSize, this.maxPages, this.maxItems);

  static const fromMap = PageInfoMapper.fromMap;
  static const fromJson = PageInfoMapper.fromJson;
}

class PaginatedList<T extends UniSystemModel> implements Comparable<PaginatedList<T>>{
  PageInfo pageInfo;
  Set<T> set;

  PaginatedList({required this.pageInfo, required this.set});

  Set<T> searchInPage (String search) {
    final searchAsNumber = num.tryParse(search);
    if (searchAsNumber != null) {
      return set.where((element) => element.hasNumberMatch(searchAsNumber)).toSet();
    } else {
      return set.where((element) => element.hasStringMatch(search)).toSet();
    }
  }

  @override
  int compareTo(other) {
    if (pageInfo.currentPage == other.pageInfo.currentPage) {
      return 0;
    } else if (pageInfo.currentPage > other.pageInfo.currentPage) {
      return 1;
    } else {
      return -1;
    }
  }
}

class PaginatedInfiniteList<T extends UniSystemModel> {
  ///contains all the inserted [PageInfo]
  SplayTreeSet<PaginatedList<T>> paginatedListsTree = SplayTreeSet();

  ///Last snapshot of tree, does not update until next call to [getTreeSnapshotAsList]
  List<T>? _listCache;

  PaginatedInfiniteList(PaginatedList<T> initialPage) {
    paginatedListsTree.add(initialPage);
  }

  void addPage(PaginatedList<T> newPage) {
    if (newPage.pageInfo.maxPages == paginatedListsTree.first.pageInfo.maxPages) {
      paginatedListsTree.add(newPage);
    } else {
      throw const FormatException("pages must have same max dimensions as initial page");
    }
  }

  List<T> getCacheOrTreeSnapshotAsList() {
    if (_listCache != null) {
      return _listCache!;
    } else {
      return getTreeSnapshotAsList();
    }
  }

  List<T> getTreeSnapshotAsList() {
    _listCache = paginatedListsTree.map((element) => element.set.toList()).reduce((value, element) => value..addAll(element));
    return _listCache!;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedInfiniteList && runtimeType == other.runtimeType && paginatedListsTree == other.paginatedListsTree;

  @override
  int get hashCode => paginatedListsTree.hashCode;
}
