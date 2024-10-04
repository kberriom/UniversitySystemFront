import 'package:university_system_front/Model/uni_system_model.dart';

final class SearchService<T extends UniSystemModel> {
  late final Future<List<T>> _unfilteredList;
  late final Future<List<T>> _excludeList;

  List<T>? _filteredList;

  SearchService({
    required Future<List<T>> unfilteredList,
  })  : _unfilteredList = unfilteredList,
        _excludeList = Future<List<T>>.value(const []);

  SearchService.exclude({
    required Future<List<T>> unfilteredList,
    required Future<List<T>> excludeList,
  })  : _excludeList = excludeList,
        _unfilteredList = unfilteredList;

  Future<List<T>> _excludeFilter() async {
    final futures = await Future.wait([_unfilteredList, _excludeList]);
    return futures[0].where((subject) => !futures[1].contains(subject)).toList(growable: false);
  }

  Future<List<T>> findBySearchTerm(String search) async {
    _filteredList = _filteredList ?? (await _excludeFilter());
    if (search.isNotEmpty) {
      final lowerCaseSearch = search.toLowerCase();
      final numSearch = num.tryParse(search) ?? double.nan;
      return <T>[..._filteredList!.where((item) => item.hasStringMatch(lowerCaseSearch) || item.hasNumberMatch(numSearch))];
    } else {
      return _filteredList!;
    }
  }
}
