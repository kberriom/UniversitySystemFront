import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/uni_system_model.dart';

part 'subject.mapper.dart';

@MappableClass()
class Subject extends UniSystemModel<int> with SubjectMappable{
  @override
  int id;
  String name;
  String description;
  String startDate;
  String endDate;
  bool remote;
  bool onSite;
  String? roomLocation;
  int creditsValue;

  static const fromMap = SubjectMapper.fromMap;
  static const fromJson = SubjectMapper.fromJson;

  Subject(
      {required this.id,
      required this.name,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.remote,
      required this.onSite,
      this.roomLocation,
      required this.creditsValue});

  @override
  bool hasNumberMatch(num search) {
    return id == search || creditsValue == search || startDate.contains(search.toString()) || endDate.contains(search.toString());
  }

  @override
  bool hasStringMatch(String search) {
    return bestMatch(search: search, stringList: [
      name.toLowerCase(),
      description.toLowerCase(),
      'remote = $remote',
      'onSite = $onSite',
      if (roomLocation != null) roomLocation!.toLowerCase(),
    ]);
  }
}

@MappableClass()
class SubjectDto with SubjectDtoMappable {
  String? name;
  String? description;
  String? startDate;
  String? endDate;
  bool? remote;
  bool? onSite;
  String? roomLocation;
  int? creditsValue;

  SubjectDto(
      {this.name,
      this.description,
      this.startDate,
      this.endDate,
      this.remote,
      this.onSite,
      this.roomLocation,
      this.creditsValue});

  static const fromMap = SubjectDtoMapper.fromMap;
  static const fromJson = SubjectDtoMapper.fromJson;
}
