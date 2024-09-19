import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mutex/mutex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:university_system_front/Repository/users/student_repository.dart';
import 'package:university_system_front/Repository/users/teacher_repository.dart';
import 'package:university_system_front/Util/provider_utils.dart';

part 'admin_users_widget_controller.g.dart';

part 'admin_users_widget_controller.freezed.dart';

///Amount of users to fetch on a request.
///
///Must be the same for all PageInfo in PaginatedInfiniteList
const int preCacheAmount = 20;

@freezed
class UserListItemPackage with _$UserListItemPackage {
  const factory UserListItemPackage({User? userData}) = _UserListItemPackage;
}

final selfAwareUserListItemLock = Mutex();

///A provider that returns [ListItemPackage] if it's ok to build an item, does not complete the future while loading the item info,
///and returns null if the item should not be built.
@riverpod
class SelfAwareUserListItem extends _$SelfAwareUserListItem {
  @override
  Future<UserListItemPackage> build(int pageIndex, bool showTeacherList, bool showStudentList) async {
    if (pageIndex < 0) {
      throw const FormatException("Page item index must start at 0");
    } else {
      //list index starts from 0, page item index starts from 1
      pageIndex += 1;
    }

    //Protect with lock, heavy computation will only occur on cache miss
    //Lag will only become apparent on very low preCacheAmount < 10
    assert(preCacheAmount >= 10);
    return await selfAwareUserListItemLock.protect<UserListItemPackage>(() async {
      PaginatedInfiniteList<Student> pgStudentList =
          (await ref.watch(paginatedUserInfiniteListProvider.call(UserRole.student).future)) as PaginatedInfiniteList<Student>;
      PaginatedInfiniteList<Teacher> pgTeacherList =
          (await ref.watch(paginatedUserInfiniteListProvider.call(UserRole.teacher).future)) as PaginatedInfiniteList<Teacher>;

      //Students get build first on list
      PaginatedInfiniteList pgUserList;
      UserRole type;
      final maxItemsInStudentList = pgStudentList.paginatedListsTree.first.pageInfo.maxItems;
      if (showStudentList && pageIndex <= maxItemsInStudentList) {
        pgUserList = pgStudentList;
        type = UserRole.student;
      } else {
        //Offset teacher page index to 1 -> n instead of 1+m -> n+m
        pageIndex -= (showStudentList && (maxItemsInStudentList > 0)) ? maxItemsInStudentList : 0;
        pgUserList = pgTeacherList;
        type = UserRole.teacher;
      }

      PageInfo firstPageInfo = pgUserList.paginatedListsTree.first.pageInfo;
      PageInfo lastPageInfo = pgUserList.paginatedListsTree.last.pageInfo;
      if (firstPageInfo.maxPages == lastPageInfo.currentPage) {
        if (lastPageInfo.currentPageSize == 0) {
          //Do not build => No more items, is on last posible page and current page has no items or no user type registered
          return const UserListItemPackage(userData: null);
        }
        //On last page and items
        final int totalPageIndex =
            ((firstPageInfo.currentPageSize * (lastPageInfo.currentPage - 1)) + lastPageInfo.currentPageSize);
        if (pageIndex <= totalPageIndex) {
          final fetchedItemFromCacheOfOnePage = _getItemAtLengthCached(type, pageIndex, pgTeacherList, pgStudentList);
          return fetchedItemFromCacheOfOnePage;
        } else {
          return const UserListItemPackage(userData: null);
        }
      }
      //On n-1 page and items
      if (pageIndex <= pgUserList.getCacheOrTreeSnapshotAsList().length) {
        //build widget => Item is already in tree
        final fetchedItemFromTree = _getItemAtLengthCached(type, pageIndex, pgTeacherList, pgStudentList);

        return fetchedItemFromTree;
      } else {
        //await for new items => Not in tree but item is valid
        int uncommittedNewMaxPage = lastPageInfo.currentPage;
        do {
          //Fetch new page
          uncommittedNewMaxPage += 1;
          PaginatedList userPage;
          if (type == UserRole.student) {
            userPage = await ref.read(studentRepositoryProvider).getAllUserTypeInfoPaged(uncommittedNewMaxPage, preCacheAmount);
          } else {
            userPage = await ref.read(teacherRepositoryProvider).getAllUserTypeInfoPaged(uncommittedNewMaxPage, preCacheAmount);
          }
          if (userPage.pageInfo.currentPageSize == 0) {
            //Oops new page is empty, so we are tying to get info that does not exist
            //Do not build any more
            return const UserListItemPackage(userData: null);
          }
          if (pgUserList.paginatedListsTree.last != userPage) {
            pgUserList.addPage(userPage);
          }
        } while (pageIndex > pgUserList.getTreeSnapshotAsList().length);
        //Item is now in tree and can be built
        final fetchedItemFromLoop = _getItemAtLengthCached(type, pageIndex, pgTeacherList, pgStudentList);
        return fetchedItemFromLoop;
      }
    });
  }

  UserListItemPackage _getItemAtLengthCached(
      UserRole type, int pageIndex, PaginatedInfiniteList<Teacher> pgTeacherList, PaginatedInfiniteList<Student> pgStudentList) {
    final int listIndex = pageIndex - 1;
    if (type == UserRole.student) {
      return UserListItemPackage(userData: pgStudentList.getCacheOrTreeSnapshotAsList()[listIndex]);
    } else {
      return UserListItemPackage(userData: pgTeacherList.getCacheOrTreeSnapshotAsList()[listIndex]);
    }
  }
}

@riverpod
Future<PaginatedInfiniteList<User>> paginatedUserInfiniteList(PaginatedUserInfiniteListRef ref, UserRole type) async {
  if (type == UserRole.student) {
    PaginatedList<Student> studentPage = await ref.read(studentRepositoryProvider).getAllUserTypeInfoPaged(1, preCacheAmount);
    return PaginatedInfiniteList<Student>(studentPage);
  } else {
    PaginatedList<Teacher> teacherPage = await ref.read(teacherRepositoryProvider).getAllUserTypeInfoPaged(1, preCacheAmount);
    return PaginatedInfiniteList<Teacher>(teacherPage);
  }
}

@riverpod
class AdminUsersWidgetController extends _$AdminUsersWidgetController {
  @override
  Future<List<User?>> build(bool showTeacherList, bool showStudentList, String searchTerm, {bool getAll = false}) async {
    List<User?> usersList = [];
    if (searchTerm.isNotEmpty) {
      searchTerm = searchTerm.toLowerCase();
    }

    if (getAll) {
      num intSearchTerm = int.tryParse(searchTerm) ?? double.nan;
      if (showStudentList) {
        final allStudents = await ref.watch(fullUserListProvider.call(UserRole.student).future);
        if (searchTerm.isNotEmpty) {
          usersList.addAll(
              allStudents.where((student) => student.hasStringMatch(searchTerm) || student.hasNumberMatch(intSearchTerm)));
        } else {
          usersList.addAll(allStudents);
        }
      }
      if (showTeacherList) {
        final allTeachers = await ref.watch(fullUserListProvider.call(UserRole.teacher).future);
        if (searchTerm.isNotEmpty) {
          usersList.addAll(
              allTeachers.where((teacher) => teacher.hasStringMatch(searchTerm) || teacher.hasNumberMatch(intSearchTerm)));
        } else {
          usersList.addAll(allTeachers);
        }
      }
      ref.keepFor(const Duration(minutes: 10));
      return usersList;
    }

    PaginatedInfiniteList<Student> studentPages =
        (await ref.watch(paginatedUserInfiniteListProvider.call(UserRole.student).future)) as PaginatedInfiniteList<Student>;
    PaginatedInfiniteList<Teacher> teacherPages =
        (await ref.watch(paginatedUserInfiniteListProvider.call(UserRole.teacher).future)) as PaginatedInfiniteList<Teacher>;

    if (searchTerm.isNotEmpty) {
      if (showStudentList) {
        Set<Student> searchResults = {};
        for (var page in studentPages.paginatedListsTree) {
          searchResults.addAll(page.searchInPage(searchTerm));
        }
        usersList.addAll(searchResults);
      }
      if (showTeacherList) {
        Set<Teacher> searchResults = {};
        for (var page in teacherPages.paginatedListsTree) {
          searchResults.addAll(page.searchInPage(searchTerm));
        }
        usersList.addAll(searchResults);
      }
      ref.keepFor(const Duration(minutes: 5));
    } else {
      if (showStudentList) {
        usersList.addAll(studentPages.getCacheOrTreeSnapshotAsList());
        var maxStudents = studentPages.paginatedListsTree.first.pageInfo.maxItems;
        var currentLocalStudents = studentPages.getCacheOrTreeSnapshotAsList().length;
        if (maxStudents != 0 && currentLocalStudents < maxStudents) {
          usersList.addAll(List<Student?>.generate(maxStudents - currentLocalStudents, (index) => null));
        }
      }
      if (showTeacherList) {
        usersList.addAll(teacherPages.getCacheOrTreeSnapshotAsList());
        var maxTeachers = teacherPages.paginatedListsTree.first.pageInfo.maxItems;
        var currentLocalTeachers = teacherPages.getCacheOrTreeSnapshotAsList().length;
        if (maxTeachers != 0 && currentLocalTeachers < maxTeachers) {
          usersList.addAll(List<Teacher?>.generate(maxTeachers - currentLocalTeachers, (index) => null));
        }
      }
      ref.keepFor(const Duration(minutes: 10));
    }
    return usersList;
  }
}

@riverpod
Future<List<User>> fullUserList(FullUserListRef ref, UserRole userRole) async {
  switch (userRole) {
    case UserRole.admin:
      throw UnimplementedError();
    case UserRole.teacher:
      return await ref.read(teacherRepositoryProvider).getAllUserTypeInfo();
    case UserRole.student:
      return await ref.read(studentRepositoryProvider).getAllUserTypeInfo();
  }
}
