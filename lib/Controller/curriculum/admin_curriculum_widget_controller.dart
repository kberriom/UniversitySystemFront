import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutex/mutex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Controller/paginated_infinite_list_generic_controller.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Repository/curriculum/curriculum_repository.dart';
import 'package:university_system_front/Util/provider_utils.dart';
import 'package:university_system_front/Model/uni_system_model.dart';

part 'admin_curriculum_widget_controller.g.dart';

part 'admin_curriculum_widget_controller.mapper.dart';

///Amount of curriculums to fetch on a request.
///
///Must be the same for all requests
const int preCacheAmount = 20;

@MappableClass()
class CurriculumListItemPackage with CurriculumListItemPackageMappable implements ListItemPackage<Curriculum> {
  @override
  Curriculum? itemData;

  CurriculumListItemPackage({this.itemData});
}

final curriculumListItemLock = Mutex();

///A provider that returns [CurriculumListItemPackage] if it's ok to build an item, does not complete the future while loading the item info,
///and returns null if the item should not be built.
@riverpod
class SelfAwareCurriculumListItem extends _$SelfAwareCurriculumListItem {
  @override
  Future<CurriculumListItemPackage> build(int pageIndex) async {
    final selfAwareListItem = SelfAwareListItem<Curriculum>(
      listTypeLock: curriculumListItemLock,
      infiniteListCallback: () async {
        return ref.watch(paginatedCurriculumInfiniteListProvider.future);
      },
      newPageCallback: (int page) {
        return ref.read(curriculumRepositoryProvider).getAllCurriculumsPaged(page, preCacheAmount);
      },
    );
    return CurriculumListItemPackage(itemData: await selfAwareListItem.computeItem(pageIndex));
  }
}

@riverpod
Future<PaginatedInfiniteList<Curriculum>> paginatedCurriculumInfiniteList(Ref ref) async {
  PaginatedList<Curriculum> curriculumPage =
      await ref.read(curriculumRepositoryProvider).getAllCurriculumsPaged(1, preCacheAmount);
  return PaginatedInfiniteList<Curriculum>(curriculumPage);
}

@riverpod
class AdminSubjectsWidgetController extends _$AdminSubjectsWidgetController {
  @override
  Future<List<Curriculum?>> build(String searchTerm) async {
    PaginatedInfiniteList<Curriculum> curriculumPages = await ref.watch(paginatedCurriculumInfiniteListProvider.future);
    final curriculumController = BaseInfiniteListController<Curriculum>(curriculumPages);
    final List<Curriculum?> result = curriculumController.computeProvider(searchTerm);
    ref.keepFor(searchTerm.isNotEmpty ? const Duration(minutes: 5) : const Duration(minutes: 10));
    return result;
  }
}
