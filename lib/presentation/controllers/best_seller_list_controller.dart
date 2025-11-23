import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../models/list_category.dart';
import '../service/api_service.dart';


class BestSellerListController extends GetxController {
  var bestSellerLists = <ListCategory>[].obs;
  var isLoading = false.obs;
  final ApiService apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchBestSellerCategories();
  }

  Future<void> fetchBestSellerCategories() async {
    try {
      isLoading.value = true;
      final response = await apiService.getBestSellerListNames();
      if (response.statusCode == 200) {
        bestSellerLists.value = parseCategories(response.bodyString!);
      } else {
        if (kDebugMode) {
          print('Failed to fetch data: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<ListCategory> parseCategories(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return (parsed['results'] as List)
        .map((data) => ListCategory.fromJson(data))
        .toList();
  }
}
