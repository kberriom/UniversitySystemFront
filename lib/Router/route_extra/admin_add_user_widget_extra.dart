import 'package:dart_mappable/dart_mappable.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';

part 'admin_add_user_widget_extra.mapper.dart';

@MappableClass()
class AdminAddUserWidgetExtra with AdminAddUserWidgetExtraMappable {
  Set<UserRole> selectedUserType;

  AdminAddUserWidgetExtra({required this.selectedUserType});

  static const fromMap = AdminAddUserWidgetExtraMapper.fromMap;
  static const fromJson = AdminAddUserWidgetExtraMapper.fromJson;
}
