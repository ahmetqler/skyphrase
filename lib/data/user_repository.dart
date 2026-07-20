import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameTakenException implements Exception {}

/// Kullanıcı adı benzersizliğini ve kullanıcı profillerini Firestore'da
/// yönetir. `usernames/{kullanıcıAdıKüçükHarf}` belgesi kimin bu adı
/// aldığını tutar; bir işlem (transaction) içinde önce bu belgenin var
/// olup olmadığına bakılır, yoksa hem bu belge hem de profil belgesi
/// birlikte oluşturulur — böylece iki kullanıcı aynı anda kayıt olsa bile
/// aynı kullanıcı adını asla ikisi birden alamaz.
class UserRepository {
  final _db = FirebaseFirestore.instance;

  String _normalize(String username) => username.trim().toLowerCase();

  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _db.collection('usernames').doc(_normalize(username)).get();
    return !doc.exists;
  }

  /// Kullanıcı adını rezerve eder ve profil belgesini oluşturur. Kullanıcı
  /// adı bu sırada başkası tarafından alınmışsa [UsernameTakenException]
  /// fırlatır.
  Future<void> claimUsernameAndCreateProfile({
    required String uid,
    required String username,
    required String email,
  }) async {
    final usernameKey = _normalize(username);
    final usernameRef = _db.collection('usernames').doc(usernameKey);
    final userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((tx) async {
      final existing = await tx.get(usernameRef);
      if (existing.exists) {
        throw UsernameTakenException();
      }
      tx.set(usernameRef, {
        'uid': uid,
        'username': username,
        'email': email,
      });
      tx.set(userRef, {
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'xp': 0,
        'streak': 0,
        'weeklyXp': 0,
        'completedLessons': <String>[],
      });
    });
  }

  /// Kullanıcı adıyla giriş yapılabilmesi için kullanıcı adını e-postaya
  /// çözer (Firebase Auth e-posta ile giriş yapar, kullanıcı adı sadece
  /// görünen profil bilgisidir).
  Future<String?> emailForUsername(String username) async {
    final doc = await _db.collection('usernames').doc(_normalize(username)).get();
    return doc.data()?['email'] as String?;
  }

  /// Verilen kullanıcı adının uid'sini döner (arkadaş isteği göndermek
  /// için). Bulunamazsa null.
  Future<String?> uidForUsername(String username) async {
    final doc = await _db.collection('usernames').doc(_normalize(username)).get();
    return doc.data()?['uid'] as String?;
  }

  /// Arkadaş ararken kullanılır: kullanıcı adı [prefix] ile başlayan
  /// hesapları döner (küçük harfe göre, belge id'si zaten normalize
  /// kullanıcı adı olduğu için ek bir alan indekslemeye gerek yok).
  /// Aralığın üst sınırı, prefix'in son karakterini bir artırarak elde
  /// edilir (ör. "de" -> "df") — özel bir unicode karakter gerektirmez.
  Future<List<({String uid, String username})>> searchUsernames(
    String prefix, {
    int limit = 8,
  }) async {
    final normalized = _normalize(prefix);
    if (normalized.isEmpty) return const [];
    final codeUnits = normalized.codeUnits.toList();
    codeUnits[codeUnits.length - 1] = codeUnits.last + 1;
    final upperBound = String.fromCharCodes(codeUnits);
    final snap = await _db
        .collection('usernames')
        .orderBy(FieldPath.documentId)
        .startAt([normalized])
        .endBefore([upperBound])
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => (
              uid: d.data()['uid'] as String,
              username: d.data()['username'] as String,
            ))
        .toList();
  }
}
