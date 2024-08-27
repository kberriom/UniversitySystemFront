import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mutex/mutex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Controller/paginated_infinite_list_generic_controller.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';
import 'package:university_system_front/Util/provider_utils.dart';

part 'admin_subjects_widget_controller.g.dart';

part 'admin_subjects_widget_controller.freezed.dart';

///Amount of subjects to fetch on a request.
///
///Must be the same for all PageInfo in PaginatedInfiniteList
const int preCacheAmount = 20;

@freezed
class SubjectsListItemPackage with _$SubjectsListItemPackage {
  const factory SubjectsListItemPackage({Subject? subjectData}) = _SubjectsListItemPackage;
}

final subjectListItemLock = Mutex();

///A provider that returns [SubjectsListItemPackage] if it's ok to build an item, does not complete the future while loading the item info,
///and returns null if the item should not be built.
@riverpod
class SelfAwareSubjectListItem extends _$SelfAwareSubjectListItem {
  @override
  Future<SubjectsListItemPackage> build(int pageIndex) async {
    final selfAwareListItem = SelfAwareListItem<Subject>(
      listTypeLock: subjectListItemLock,
      infiniteListCallback: () async {
        return ref.watch(paginatedSubjectInfiniteListProvider.future);
      },
      newPageCallback: (int page) {
        return ref.read(subjectRepositoryImplProvider).getAllSubjectsPaged(page, preCacheAmount);
      },
    );
    return SubjectsListItemPackage(subjectData: await selfAwareListItem.computeItem(pageIndex));
  }
}

@riverpod
Future<PaginatedInfiniteList<Subject>> paginatedSubjectInfiniteList(PaginatedSubjectInfiniteListRef ref) async {
  PaginatedList<Subject> subjectPage = await ref.read(subjectRepositoryImplProvider).getAllSubjectsPaged(1, preCacheAmount);
  return PaginatedInfiniteList<Subject>(subjectPage);
}

@riverpod
class AdminSubjectsWidgetController extends _$AdminSubjectsWidgetController {
  @override
  Future<List<Subject?>> build(String searchTerm) async {
    PaginatedInfiniteList<Subject> subjectPages = await ref.watch(paginatedSubjectInfiniteListProvider.future);
    final subjectController = BaseInfiniteListController<Subject>(subjectPages);
    final List<Subject?> result = subjectController.computeProvider(searchTerm);
    ref.keepFor(searchTerm.isNotEmpty ? const Duration(minutes: 5) : const Duration(minutes: 10));
    return result;
  }
}
