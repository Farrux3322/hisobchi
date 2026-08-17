
import 'package:ehisob/infrastructure/common/network_provider.dart';

class AuthRepositoryImpl {
  Future<Map<String, dynamic>> getMe() async {
    final response = await dio.get(
      "v1/auth/me",
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSection({required int status}) async {
    final response = await dio.get("sections", data: {'status': status});
    return response.data;
  }

  Future<Map<String, dynamic>> getFavoriteSection() async {
    final response = await dio.get("get-ordered-favorite-section");
    return response.data;
  }


  Future<Map<String, dynamic>> changeSection({required int status, required List<int> ids}) async {
    final response = await dio.post("section-store", data: {
      'status': status,
      'ids': ids,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> changeFavoriteSection({ required List<int> ids}) async {
    final response = await dio.post("favorite-section-store", data: {
      'favorite_section_ids': ids,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> favoriteSelected({required int status, required List<int> ids}) async {
    final response = await dio.post("section-favorite-store", data: {
      'status': status,
      'ids': ids,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getFavorite() async {
    final response = await dio.get("favorite-sections");
    return response.data;
  }

  Future<Map<String, dynamic>> deleteFavorite({required int id,required List<int?> ids}) async {
    final response = await dio.delete("retrieve-from-favorite",data: {
      'ids':[id],
      'stayed_ids':ids
    });
    return response.data;
  }

}
