import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirestoreCacheService extends GetxService {
  Future<QuerySnapshot<Map<String, dynamic>>> queryGet(
    Query<Map<String, dynamic>> query, {
    bool forceRefresh = false,
  }) async {
    final source = forceRefresh ? Source.server : Source.serverAndCache;

    try {
      return await query.get(GetOptions(source: source));
    } catch (_) {
      return query.get(const GetOptions(source: Source.server));
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> docGet(
    DocumentReference<Map<String, dynamic>> reference, {
    bool forceRefresh = false,
  }) async {
    final source = forceRefresh ? Source.server : Source.serverAndCache;

    try {
      return await reference.get(GetOptions(source: source));
    } catch (_) {
      return reference.get(const GetOptions(source: Source.server));
    }
  }
}
