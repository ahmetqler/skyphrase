import 'package:cloud_firestore/cloud_firestore.dart';

class AlreadyFriendsException implements Exception {}

class CannotFriendSelfException implements Exception {}

/// Bir arkadaşlık/istek kaydı. `friendships/{pairId}` belgesinde tutulur —
/// pairId iki uid'nin alfabetik sırayla birleşimidir, böylece A→B ve B→A
/// için hep aynı tek belge kullanılır (çift kayıt oluşmaz).
class FriendshipRecord {
  final String pairId;
  final List<String> uids;
  final String requestedBy;
  final String status; // 'pending' | 'accepted'
  const FriendshipRecord({
    required this.pairId,
    required this.uids,
    required this.requestedBy,
    required this.status,
  });

  String otherUid(String myUid) => uids.firstWhere((u) => u != myUid);
  bool isIncomingFor(String myUid) => status == 'pending' && requestedBy != myUid;
  bool isOutgoingFor(String myUid) => status == 'pending' && requestedBy == myUid;

  factory FriendshipRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FriendshipRecord(
      pairId: doc.id,
      uids: (data['uids'] as List).cast<String>(),
      requestedBy: data['requestedBy'] as String,
      status: data['status'] as String,
    );
  }
}

/// Arkadaşlık ilişkilerini `friendships` koleksiyonunda yönetir. Tasarım
/// kasıtlı olarak basit tutuldu: her çift için TEK bir belge (iki ayrı
/// yönde belge yok), durum "pending" ya da "accepted". Kabul edilen
/// arkadaşların profil verisi (xp/streak) ayrıca `users/{uid}`'den
/// okunur — burada tekrar saklanmaz, böylece güncelliğini kaybetmez ve
/// her XP kazanımında ekstra yazma maliyeti oluşmaz.
class FriendsRepository {
  final _db = FirebaseFirestore.instance;

  String pairId(String a, String b) => a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';

  CollectionReference<Map<String, dynamic>> get _friendships =>
      _db.collection('friendships');

  Future<void> sendRequest({required String myUid, required String theirUid}) async {
    if (myUid == theirUid) throw CannotFriendSelfException();
    final id = pairId(myUid, theirUid);
    final ref = _friendships.doc(id);
    final existing = await ref.get();
    if (existing.exists) throw AlreadyFriendsException();
    await ref.set({
      'uids': myUid.compareTo(theirUid) < 0 ? [myUid, theirUid] : [theirUid, myUid],
      'requestedBy': myUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptRequest(String pairId) async {
    await _friendships.doc(pairId).update({'status': 'accepted'});
  }

  /// İsteği reddetmek, gönderilen isteği geri çekmek ya da mevcut bir
  /// arkadaşlığı kaldırmak — hepsi aynı işlem: belgeyi sil.
  Future<void> deleteFriendship(String pairId) async {
    await _friendships.doc(pairId).delete();
  }

  Future<List<FriendshipRecord>> fetchMyFriendships(String myUid) async {
    final snap = await _friendships.where('uids', arrayContains: myUid).get();
    return snap.docs.map(FriendshipRecord.fromDoc).toList();
  }

  /// Liderlik tablosu / arkadaş listesi için bir kullanıcının güncel
  /// profil özetini okur.
  Future<({String username, int xp, int weeklyXp, int streak})?> fetchProfileSummary(
    String uid,
  ) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return (
      username: data['username'] as String? ?? '?',
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      weeklyXp: (data['weeklyXp'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
    );
  }
}
