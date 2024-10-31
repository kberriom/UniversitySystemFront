import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/users/user.dart';

///[T] Student or teacher
///[TDTO] DTO class of selected user type
abstract interface class UserRepository<T extends User, UDTO extends Object> {
  Future<T> getUserTypeInfo(BearerToken selfIdentityToken);

  Future<T> getUserTypeInfoById(int id);

  Future<List<T>> getAllUserTypeInfo();

  Future<PaginatedList<T>> getAllUserTypeInfoPaged(int page, int size);

  Future<void> deleteUserTypeInfo(BearerToken selfIdentityToken);

  Future<void> deleteUserTypeInfoById(int id);

  Future<T> updateUserTypeInfo(UDTO updateDto);

  Future<T> updateUserTypeInfoById(int id, UDTO updateDto);
}
