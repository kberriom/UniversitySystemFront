import 'package:string_similarity/string_similarity.dart';

///Minimum contract that any University System Model is expected to fulfil
abstract class UniSystemModel<ID> implements UniSystemModelId<ID> {
  ///[search] is expected to be lowercase
  bool hasStringMatch(String search);

  bool hasNumberMatch(num search);
}

abstract class UniSystemModelId<T> {
  late final T id;
}

abstract interface class ListItemPackage<T extends UniSystemModel> {
  late T? itemData;
}

bool bestMatch({required String search, required List<String> stringList, double threshold = 0.5}) {
  final match = search.bestMatch(stringList);
  return (match.bestMatch.rating ?? 0) > threshold;
}
