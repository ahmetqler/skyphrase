import 'package:flutter/foundation.dart';
import '../data/friends_repository.dart';
import '../data/user_repository.dart';

/// Kabul edilmiş bir arkadaş — liderlik tablosunda gösterilir.
class FriendEntry {
  final String pairId;
  final String uid;
  final String username;
  final int xp;
  final int weeklyXp;
  final int streak;
  const FriendEntry({
    required this.pairId,
    required this.uid,
    required this.username,
    required this.xp,
    required this.weeklyXp,
    required this.streak,
  });
}

/// Bekleyen bir istek — gelen (biri sana istek attı) ya da giden (sen
/// birine istek attın, henüz onaylamadı).
class PendingRequest {
  final String pairId;
  final String uid;
  final String username;
  const PendingRequest({required this.pairId, required this.uid, required this.username});
}

class UsernameMatch {
  final String uid;
  final String username;
  const UsernameMatch({required this.uid, required this.username});
}

enum SendRequestResult { success, alreadyExists, cannotAddSelf, error }

/// Arkadaşlar sekmesini besler. Firestore'daki `friendships` koleksiyonu
/// ve her arkadaşın kendi `users/{uid}` profilinden okunur (bkz.
/// FriendsRepository) — cihazda üretilen sahte veri yok. Diğer
/// provider'larla tutarlı olsun diye (bkz. ProgressProvider) canlı
/// dinleyici (`.snapshots()`) yerine tek seferlik okuma + `refresh()`
/// kullanılır, böylece Firestore okuma kotası gereksiz yere tüketilmez.
class FriendsProvider extends ChangeNotifier {
  final _repo = FriendsRepository();
  final _userRepo = UserRepository();

  String? _myUid;
  bool _loaded = false;
  bool _refreshing = false;
  List<FriendEntry> _friends = const [];
  List<PendingRequest> _incoming = const [];
  List<PendingRequest> _outgoing = const [];
  Object? _error;

  bool get isLoaded => _loaded;
  bool get isRefreshing => _refreshing;
  List<FriendEntry> get friends => _friends;
  List<PendingRequest> get incomingRequests => _incoming;
  List<PendingRequest> get outgoingRequests => _outgoing;
  Object? get error => _error;

  Future<void> bind(String uid) async {
    if (_myUid == uid && _loaded) return;
    _myUid = uid;
    _loaded = false;
    notifyListeners();
    await refresh();
  }

  void unbind() {
    _myUid = null;
    _friends = const [];
    _incoming = const [];
    _outgoing = const [];
    _loaded = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final uid = _myUid;
    if (uid == null) return;
    _refreshing = true;
    notifyListeners();

    try {
      final records = await _repo.fetchMyFriendships(uid);
      final accepted = records.where((r) => r.status == 'accepted').toList();
      final incoming = records.where((r) => r.isIncomingFor(uid)).toList();
      final outgoing = records.where((r) => r.isOutgoingFor(uid)).toList();

      final friendEntries = (await Future.wait(accepted.map((r) async {
        final otherUid = r.otherUid(uid);
        final profile = await _repo.fetchProfileSummary(otherUid);
        if (profile == null) return null;
        return FriendEntry(
          pairId: r.pairId,
          uid: otherUid,
          username: profile.username,
          xp: profile.xp,
          weeklyXp: profile.weeklyXp,
          streak: profile.streak,
        );
      })))
          .whereType<FriendEntry>()
          .toList()
        ..sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));

      _incoming = await Future.wait(incoming.map((r) => _toPending(r, uid)));
      _outgoing = await Future.wait(outgoing.map((r) => _toPending(r, uid)));
      _friends = friendEntries;
      _error = null;
    } catch (e) {
      // Yükleme takılı kalmasın diye hatayı da "yüklendi" sayıyoruz —
      // ekran boş/hata durumunu gösterip tekrar dene imkânı sunuyor.
      _error = e;
    } finally {
      _refreshing = false;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<PendingRequest> _toPending(FriendshipRecord r, String myUid) async {
    final otherUid = r.otherUid(myUid);
    final profile = await _repo.fetchProfileSummary(otherUid);
    return PendingRequest(pairId: r.pairId, uid: otherUid, username: profile?.username ?? '?');
  }

  /// Kullanıcı adına göre arkadaş adayı arar; zaten arkadaş olduğun ya da
  /// aranızda bekleyen bir istek bulunan hesapları sonuçlardan eler.
  Future<List<UsernameMatch>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final results = await _userRepo.searchUsernames(trimmed);
    final knownUids = {
      if (_myUid != null) _myUid!,
      ..._friends.map((f) => f.uid),
      ..._incoming.map((r) => r.uid),
      ..._outgoing.map((r) => r.uid),
    };
    return results
        .where((r) => !knownUids.contains(r.uid))
        .map((r) => UsernameMatch(uid: r.uid, username: r.username))
        .toList();
  }

  Future<SendRequestResult> sendRequest(String theirUid) async {
    final uid = _myUid;
    if (uid == null || uid == theirUid) return SendRequestResult.cannotAddSelf;
    try {
      await _repo.sendRequest(myUid: uid, theirUid: theirUid);
      await refresh();
      return SendRequestResult.success;
    } on AlreadyFriendsException {
      return SendRequestResult.alreadyExists;
    } on CannotFriendSelfException {
      return SendRequestResult.cannotAddSelf;
    } catch (_) {
      return SendRequestResult.error;
    }
  }

  Future<void> acceptRequest(String pairId) async {
    await _repo.acceptRequest(pairId);
    await refresh();
  }

  /// Reddetmek, gönderilen isteği geri çekmek ve arkadaşlıktan çıkarmak
  /// aynı işlem: belgeyi sil.
  Future<void> removeConnection(String pairId) async {
    await _repo.deleteFriendship(pairId);
    await refresh();
  }
}
