import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.takenAt,
  });

  final String id;
  final String medicineId;
  final String medicineName;
  final DateTime takenAt;

  factory HistoryEntry.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final Timestamp? takenAtTs = data['takenAt'] as Timestamp?;
    return HistoryEntry(
      id: snapshot.id,
      medicineId: data['medicineId'] as String? ?? '',
      medicineName: data['medicineName'] as String? ?? 'İlaç',
      takenAt: takenAtTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class HistoryService {
  HistoryService._();

  static final HistoryService instance = HistoryService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;

  DocumentReference<Map<String, dynamic>>? _userDoc() {
    final user = _user;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid);
  }

  CollectionReference<Map<String, dynamic>>? _historyCollection() {
    final doc = _userDoc();
    if (doc == null) return null;
    return doc.collection('history');
  }

  Future<void> logIntake({
    required String medicineId,
    required String medicineName,
    required DateTime takenAt,
  }) async {
    final collection = _historyCollection();
    final user = _user;
    if (collection == null || user == null) return;

    await collection.add({
      'medicineId': medicineId,
      'medicineName': medicineName,
      'takenAt': Timestamp.fromDate(takenAt),
      'createdAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });
  }

  Stream<List<HistoryEntry>> watchHistory({DateTime? hideBefore}) {
    final collection = _historyCollection();
    if (collection == null) {
      return Stream.value(const <HistoryEntry>[]);
    }

    Query<Map<String, dynamic>> query = collection.orderBy('takenAt', descending: true);
    if (hideBefore != null) {
      query = query.where('takenAt', isGreaterThan: Timestamp.fromDate(hideBefore));
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(HistoryEntry.fromSnapshot).toList(),
        );
  }

  Stream<List<HistoryEntry>> watchAllHistory() => watchHistory();

  Stream<DateTime?> hiddenBeforeStream() {
    final doc = _userDoc();
    if (doc == null) {
      return Stream.value(null);
    }

    return doc.snapshots().map((snapshot) {
      final data = snapshot.data();
      final raw = data?['historyHiddenBefore'];
      if (raw is Timestamp) return raw.toDate();
      return null;
    });
  }

  Future<void> setHistoryHiddenBefore(DateTime? date) async {
    final doc = _userDoc();
    if (doc == null) return;

    if (date == null) {
      await doc.set({'historyHiddenBefore': FieldValue.delete()}, SetOptions(merge: true));
    } else {
      await doc.set({'historyHiddenBefore': Timestamp.fromDate(date)}, SetOptions(merge: true));
    }
  }
}



