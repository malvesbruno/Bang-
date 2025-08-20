class Player {
  final String uid;
  final String name;
  final String avatarPath;

  Player({
    required this.uid,
    required this.name,
    required this.avatarPath,
  });

  factory Player.fromMap(String uid, Map<dynamic, dynamic> data) {
    return Player(
      uid: uid,
      name: data['gamertag'] ?? 'Sem nome',
      avatarPath: data['currentAvatar'] ?? 'assets/imgs/default_avatar.png',
    );
  }
}