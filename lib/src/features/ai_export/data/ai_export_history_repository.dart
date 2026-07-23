import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';

final currentAiExportAuthUserIdProvider = Provider<String?>(
  (ref) => FirebaseAuth.instance.currentUser?.uid,
);

final aiExportHistoryWriterProvider = Provider<AiExportHistoryWriter>(
  (ref) => FirestoreAiExportHistoryWriter(FirebaseFirestore.instance),
);

final aiExportHistoryRepositoryProvider = Provider<AiExportHistoryRepository>(
  (ref) => FirestoreAiExportHistoryRepository(
    currentAuthUserId: ref.watch(currentAiExportAuthUserIdProvider),
    writer: ref.watch(aiExportHistoryWriterProvider),
    clock: ref.watch(clockProvider),
  ),
);

abstract interface class AiExportHistoryRepository {
  Future<void> saveHistory(AiExportHistoryDraft draft);
}

abstract interface class AiExportHistoryWriter {
  Future<void> addHistory({
    required String ownerUserId,
    required Map<String, Object?> data,
  });
}

class AiExportHistoryDraft {
  const AiExportHistoryDraft({
    required this.targetSessionIds,
    required this.referenceSessionId,
    required this.purpose,
    required this.targetAiService,
    required this.markdownContent,
    required this.jsonContent,
    required this.calculationVersion,
    required this.promptVersion,
    required this.calculationSnapshot,
    required this.customInstruction,
  });

  final List<String> targetSessionIds;
  final String? referenceSessionId;
  final String purpose;
  final String targetAiService;
  final String markdownContent;
  final Map<String, Object?> jsonContent;
  final String calculationVersion;
  final String promptVersion;
  final Map<String, Object?> calculationSnapshot;
  final String? customInstruction;
}

class AiExportHistoryFailure implements Exception {
  const AiExportHistoryFailure(this.message);

  final String message;
}

class FirestoreAiExportHistoryRepository implements AiExportHistoryRepository {
  const FirestoreAiExportHistoryRepository({
    required this.currentAuthUserId,
    required this.writer,
    required this.clock,
  });

  final String? currentAuthUserId;
  final AiExportHistoryWriter writer;
  final Clock clock;

  @override
  Future<void> saveHistory(AiExportHistoryDraft draft) async {
    final ownerUserId = currentAuthUserId;
    if (ownerUserId == null) {
      throw const AiExportHistoryFailure('ログイン状態を確認してください');
    }

    final now = clock();
    try {
      await writer.addHistory(
        ownerUserId: ownerUserId,
        data: _historyData(ownerUserId: ownerUserId, draft: draft, now: now),
      );
    } on AiExportHistoryFailure {
      rethrow;
    } on Exception {
      throw const AiExportHistoryFailure('AI出力履歴の保存に失敗しました');
    }
  }

  Map<String, Object?> _historyData({
    required String ownerUserId,
    required AiExportHistoryDraft draft,
    required DateTime now,
  }) {
    return {
      'schemaVersion': 1,
      'ownerUserId': ownerUserId,
      'targetSessionIds': draft.targetSessionIds,
      'referenceSessionId': draft.referenceSessionId,
      'purpose': draft.purpose,
      'targetAiService': draft.targetAiService,
      'markdownContent': draft.markdownContent,
      'jsonContent': draft.jsonContent,
      'calculationVersion': draft.calculationVersion,
      'promptVersion': draft.promptVersion,
      'calculationSnapshot': draft.calculationSnapshot,
      'customInstruction': draft.customInstruction,
      'aiResponseMemo': null,
      'createdAt': now,
      'updatedAt': now,
      'revision': 1,
      'isDeleted': false,
    };
  }
}

class FirestoreAiExportHistoryWriter implements AiExportHistoryWriter {
  const FirestoreAiExportHistoryWriter(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> addHistory({
    required String ownerUserId,
    required Map<String, Object?> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(ownerUserId)
        .collection('aiExportHistories')
        .add(data);
  }
}
