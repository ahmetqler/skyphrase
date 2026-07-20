import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../state/friends_provider.dart';
import '../state/progress_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_colors.dart';

/// Arkadaş ekleme + tatlı rekabet sekmesi. Bir story şeridi ve haftalık
/// lig listesiyle akışı Instagram'a benzetiyoruz; puan olarak mevcut
/// haftalık XP kullanılır. Veriler gerçek — kullanıcı adıyla arayıp istek
/// gönderiyorsun, karşı taraf kabul edince arkadaş oluyorsunuz (bkz.
/// FriendsProvider).
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    final friends = context.watch<FriendsProvider>();
    final progress = context.watch<ProgressProvider>();

    if (!friends.isLoaded || !progress.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friends.error != null) {
      return _FriendsErrorState(onRetry: friends.refresh);
    }

    final board = [
      _BoardEntry(name: Strings.you, xp: progress.weeklyXp, isYou: true),
      for (final f in friends.friends)
        _BoardEntry(name: f.username, xp: f.weeklyXp, pairId: f.pairId),
    ]..sort((a, b) => b.xp.compareTo(a.xp));

    final youIndex = board.indexWhere((e) => e.isYou);
    final rivalAbove = youIndex > 0 ? board[youIndex - 1] : null;
    final isEmpty = friends.friends.isEmpty && friends.incomingRequests.isEmpty;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: friends.refresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.people_alt, color: AppColors.primary, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    Strings.tabFriends,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.person_add_alt_1, color: AppColors.primary),
                    onPressed: () => _showAddFriendDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (friends.incomingRequests.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                      child: Text(
                        Strings.incomingRequestsTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          for (final r in friends.incomingRequests)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _RequestRow(
                                username: r.username,
                                onAccept: () => friends.acceptRequest(r.pairId),
                                onDecline: () => friends.removeConnection(r.pairId),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            Strings.noFriendsYetTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            Strings.noFriendsYetBody,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (friends.friends.isNotEmpty) ...[
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          for (final f in friends.friends)
                            _StoryAvatar(username: f.username, streak: f.streak),
                          _AddStoryButton(onTap: () => _showAddFriendDialog(context)),
                        ],
                      ),
                    ),
                    if (rivalAbove != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                        child: _RivalryBanner(
                          aheadName: rivalAbove.name,
                          diff: rivalAbove.xp - progress.weeklyXp,
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
                        child: _LeadingBanner(),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                      child: Text(
                        Strings.weeklyLeague,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          for (var i = 0; i < board.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _LeaderboardRow(
                                rank: i + 1,
                                entry: board[i],
                                onRemove: board[i].isYou || board[i].pairId == null
                                    ? null
                                    : () => friends.removeConnection(board[i].pairId!),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddFriendDialog(),
    );
  }
}

/// Arkadaş verisi yüklenemediğinde (izin/bağlantı hatası) gösterilir —
/// ekranın sonsuza dek yükleniyor gibi takılı kalmasını önler.
class _FriendsErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;
  const _FriendsErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              Strings.friendsLoadErrorTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              Strings.friendsLoadErrorBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(Strings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kullanıcı adıyla canlı arama yapan, sonuçlara istek gönderme
/// düğmesi ekleyen diyalog.
class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<UsernameMatch> _results = [];
  bool _searching = false;
  final Set<String> _sentTo = {};
  final Set<String> _sending = {};

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final friends = context.read<FriendsProvider>();
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final results = await friends.search(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  Future<void> _send(UsernameMatch match) async {
    setState(() => _sending.add(match.uid));
    final friends = context.read<FriendsProvider>();
    final result = await friends.sendRequest(match.uid);
    if (!mounted) return;
    setState(() {
      _sending.remove(match.uid);
      if (result == SendRequestResult.success) _sentTo.add(match.uid);
    });
    final message = switch (result) {
      SendRequestResult.success => Strings.requestSent,
      SendRequestResult.alreadyExists => Strings.requestAlreadyExists,
      _ => Strings.requestFailed,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(Strings.addFriend, style: TextStyle(color: AppColors.textPrimary)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: Strings.searchUsernameHint,
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: _searching
                  ? Center(
                      child: Text(Strings.searchingLabel,
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _controller.text.trim().isEmpty ? '' : Strings.noSearchResults,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (_, i) {
                            final match = _results[i];
                            final sent = _sentTo.contains(match.uid);
                            final sending = _sending.contains(match.uid);
                            return Row(
                              children: [
                                _InitialsAvatar(username: match.username, size: 36),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    match.username,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (sent)
                                  Icon(Icons.check_circle, color: AppColors.correct, size: 20)
                                else
                                  TextButton(
                                    onPressed: sending ? null : () => _send(match),
                                    child: sending
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(Strings.sendRequest,
                                            style: TextStyle(color: AppColors.primary)),
                                  ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(Strings.cancel, style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

class _BoardEntry {
  final String name;
  final int xp;
  final bool isYou;
  final String? pairId;
  _BoardEntry({required this.name, required this.xp, this.isYou = false, this.pairId});
}

class _RequestRow extends StatelessWidget {
  final String username;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _RequestRow({required this.username, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _InitialsAvatar(username: username, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: onDecline,
            child: Text(Strings.decline, style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: onAccept,
            child: Text(Strings.accept, style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _RivalryBanner extends StatelessWidget {
  final String aheadName;
  final int diff;
  const _RivalryBanner({required this.aheadName, required this.diff});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Strings.rivalryBehind(aheadName, diff),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingBanner extends StatelessWidget {
  const _LeadingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.correctBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.correct.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Strings.leagueLeader,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gerçek kullanıcılar profil fotoğrafı paylaşmadığı için rastgele emoji
/// yerine kullanıcı adının ilk harfini, adına göre sabit bir renkle
/// gösteririz — aynı kullanıcı her zaman aynı renkte görünür.
class _InitialsAvatar extends StatelessWidget {
  final String username;
  final double size;
  const _InitialsAvatar({required this.username, this.size = 56});

  static const _palette = [
    Color(0xFF4C9AFF), Color(0xFFFF6B6B), Color(0xFF51CF66),
    Color(0xFFFFA94D), Color(0xFFB983FF), Color(0xFF20C997),
    Color(0xFFFF8787), Color(0xFF748FFC),
  ];

  @override
  Widget build(BuildContext context) {
    final letter = username.isEmpty ? '?' : username[0].toUpperCase();
    final color = _palette[username.codeUnits.fold(0, (a, b) => a + b) % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final String username;
  final int streak;
  const _StoryAvatar({required this.username, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
              ),
              boxShadow: [
                BoxShadow(
                    color: AppColors.darken(AppColors.primary, 0.3),
                    blurRadius: 0,
                    offset: const Offset(0, 3)),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: _InitialsAvatar(username: username, size: 51),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddStoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Icon(Icons.add, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              Strings.add,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final _BoardEntry entry;
  final VoidCallback? onRemove;
  const _LeaderboardRow(
      {required this.rank, required this.entry, this.onRemove});

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: entry.isYou ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isYou ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank <= 3 ? _medals[rank - 1] : '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          entry.isYou
              ? const Text('🧑‍✈️', style: TextStyle(fontSize: 22))
              : _InitialsAvatar(username: entry.name, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.isYou ? Strings.you : entry.name,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: entry.isYou ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.bolt, size: 16, color: AppColors.accent),
              const SizedBox(width: 2),
              Text(
                '${entry.xp}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}
