
// Essa função foi criada para facilitar a lidar com o que podemos ver de outros players
class Player {
  final String uid; // id do user
  final String name; // nome do user
  final String avatarPath; // path da imagem do avatar do user

  Player({
    required this.uid,
    required this.name,
    required this.avatarPath,
  });


  // essa função transforma um map no modelo do Player
  factory Player.fromMap(String uid, Map<dynamic, dynamic> data) {
    return Player(
      uid: uid,
      name: data['gamertag'] ?? 'Sem nome',
      avatarPath: data['currentAvatar'] ?? 'assets/imgs/default_avatar.png',
    );
  }
}