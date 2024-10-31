import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';

part 'admin_subject_detail_controller.g.dart';

@riverpod
class UserCarouselDeleteMode extends _$UserCarouselDeleteMode {
  @override
  bool build(UserRole userRole) {
    return false;
  }

  void setMode(bool mode) {
    state = mode;
  }

  void toggleMode() {
    state = !state;
  }
}
