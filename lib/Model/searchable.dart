abstract class Searchable {
  ///[search] is expected to be lowercase
  bool hasStringMatch(String search);

  bool hasNumberMatch(num search);
}
