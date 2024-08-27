import 'package:mutex/mutex.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/uni_system_model.dart';

/// A SelfAwareItem is a abstract way of interpreting an item in a list that is either a [UniSystemModel] or null.
///
/// Where null indicates that at [list[index]] there is a valid [UniSystemModel] that contains the data for said [list[index]] given the current [infiniteListCallback].
///
///Lock must be the same for the list type and must not be shared between lists.
final class SelfAwareListItem<T extends UniSystemModel> {
  late final Mutex listTypeLock;
  late final Future<PaginatedInfiniteList<T>> Function() infiniteListCallback;
  late final Future<PaginatedList<T>> Function(int page) newPageCallback;

  SelfAwareListItem({required this.listTypeLock, required this.infiniteListCallback, required this.newPageCallback});

  Future<T?> computeItem(int pageIndex) async {
    if (pageIndex < 0) {
      throw const FormatException("Page item index must start at 0");
    } else {
      //list index starts from 0, page item index starts from 1
      pageIndex += 1;
    }

    //Protect with lock, heavy computation will only occur on cache miss
    return await listTypeLock.protect<T?>(() async {
      PaginatedInfiniteList<T> pgItemList = await infiniteListCallback.call();

      PageInfo firstPageInfo = pgItemList.paginatedListsTree.first.pageInfo;
      PageInfo lastPageInfo = pgItemList.paginatedListsTree.last.pageInfo;
      if (firstPageInfo.maxPages == lastPageInfo.currentPage) {
        if (lastPageInfo.currentPageSize == 0) {
          //Do not build => No more items, is on last posible page and current page has no items or no items registered
          return null;
        }
        //On last page and items
        final int totalPageIndex =
            ((firstPageInfo.currentPageSize * (lastPageInfo.currentPage - 1)) + lastPageInfo.currentPageSize);
        if (pageIndex <= totalPageIndex) {
          return _getItemAtLengthCached(pageIndex, pgItemList);
        } else {
          return null;
        }
      }
      //On n-1 page and items
      if (pageIndex <= pgItemList.getCacheOrTreeSnapshotAsList().length) {
        //build widget => Item is already in tree
        return _getItemAtLengthCached(pageIndex, pgItemList);
      } else {
        //await for new items => Not in tree but item is valid
        int uncommittedNewMaxPage = lastPageInfo.currentPage;
        do {
          //Fetch new page
          uncommittedNewMaxPage += 1;
          PaginatedList<T> itemPage = await newPageCallback.call(uncommittedNewMaxPage);
          if (itemPage.pageInfo.currentPageSize == 0) {
            //Oops new page is empty, so we are tying to get info that does not exist
            //Do not build any more
            return null;
          }
          if (pgItemList.paginatedListsTree.last != itemPage) {
            pgItemList.addPage(itemPage);
          }
        } while (pageIndex > pgItemList.getTreeSnapshotAsList().length);
        //Item is now in tree and can be built
        return _getItemAtLengthCached(pageIndex, pgItemList);
      }
    });
  }

  T _getItemAtLengthCached(int pageIndex, PaginatedInfiniteList<T> pgItemList) {
    final int listIndex = pageIndex - 1;
    return pgItemList.getCacheOrTreeSnapshotAsList()[listIndex];
  }
}

///Base controller that caches a list state to match [searchTerm].
///[PaginatedInfiniteList] contains all the raw data and
///this controller generates a list of references to items in the [PaginatedInfiniteList] or server side data not yet fetched represented as [null].
final class BaseInfiniteListController<T extends UniSystemModel> {
  final List<T?> _itemList = [];
  late final PaginatedInfiniteList<T> _itemPages;

  BaseInfiniteListController(this._itemPages);

  List<T?> computeProvider(String searchTerm) {
    if (searchTerm.isNotEmpty) {
      searchTerm = searchTerm.toLowerCase();
      Set<T> searchResults = {};
      for (var page in _itemPages.paginatedListsTree) {
        searchResults.addAll(page.searchInPage(searchTerm));
      }
      _itemList.addAll(searchResults);
    } else {
      _itemList.addAll(_itemPages.getCacheOrTreeSnapshotAsList());
      var maxItems = _itemPages.paginatedListsTree.first.pageInfo.maxItems;
      var currentLocalItems = _itemPages.getCacheOrTreeSnapshotAsList().length;
      if (maxItems != 0 && currentLocalItems < maxItems) {
        _itemList.addAll(List<T?>.generate(maxItems - currentLocalItems, (index) => null));
      }
    }
    return _itemList;
  }
}
