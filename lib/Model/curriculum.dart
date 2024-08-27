import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/uni_system_model.dart';
import 'package:university_system_front/Model/subject.dart';

part 'curriculum.mapper.dart';

@MappableClass()
class Curriculum extends UniSystemModel<int> with CurriculumMappable {
  @override
  int id;
  String name;
  String description;
  String dateStart;
  String dateEnd;
  Set<Subject>? subjects;

  Curriculum({required this.id, required this.name, required this.description, required this.dateStart, required this.dateEnd});

  static const fromMap = CurriculumMapper.fromMap;
  static const fromJson = CurriculumMapper.fromJson;

  @override
  bool hasNumberMatch(num search) {
    final numString = search.toString();
    return id == search || dateEnd.contains(numString) || dateStart.contains(numString);
  }

  @override
  bool hasStringMatch(String search) {
    return bestMatch(
        search: search,
        stringList: [
          name.toLowerCase(),
          description.toLowerCase(),
        ],
        threshold: 0.4);
  }
}

@MappableClass()
class CurriculumDTO with CurriculumDTOMappable {
  String? name;
  String? description;
  String? dateStart;
  String? dateEnd;

  CurriculumDTO({this.name, this.description, this.dateStart, this.dateEnd});

  static const fromMap = CurriculumDTOMapper.fromMap;
  static const fromJson = CurriculumDTOMapper.fromJson;
}
