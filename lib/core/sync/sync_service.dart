import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_repository.dart';

class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  final DatabaseRepository _repo = DatabaseRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if internet is available
  Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Sync all pending doubts to Firebase
  Future<void> syncDoubts() async {
    if (!await isConnected()) return;

    try {
      final unsyncedDoubts = await _repo.getUnsyncedDoubts();
      for (final doubt in unsyncedDoubts) {
        await _firestore.collection('doubts').add({
          'subject': doubt.subject,
          'question': doubt.question,
          'answer': doubt.answer ?? '',
          'is_synced': false,
          'created_at': doubt.createdAt,
          'synced_at': DateTime.now().toIso8601String(),
        });
        await _repo.markDoubtSynced(doubt.id!);
      }
    } catch (e) {
      // Silently fail — will retry next time
    }
  }

  // Listen to connectivity changes and auto sync
  void startListening() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncDoubts();
      }
    });
  }
}