// Essa classe foi criada para facilitar a atualização do banco de dados na nuvem
class Dadosuser {
  final int qtVitoria; // quantidade de vitórias do user
  final int qtDerrota; // quantidade de derrotas do user
  final int qtEmpate; // quantidade de empates do user
  final int qtGold; // quantidade de ouro do user
  final List<String> amigos; // Lista de amigos do user
  final List<String> avataresComprados; // Lista de avatares do user
  final List<String> revolveresComprados; // Lista de revolveres do user
  final String gamertag; // gamertag/nome do user
  final String currentRevolver; // revolver que o user está usando agora
  final String currentAvatar; // avatar que o user está usando agora

  Dadosuser({required this.qtVitoria, required this.qtDerrota, required this.qtEmpate, required this.qtGold,
  required this.amigos, required this.avataresComprados, required this.revolveresComprados, required this.gamertag,
  required this.currentAvatar, required this.currentRevolver});

  // essa função transforma o modelo de Dadouser em um Map
  Map<String, dynamic> toMap(){
    return {
      'qtvitoria': qtVitoria,
      'qtDerrota': qtDerrota,
      'qtEmpate': qtEmpate,
      'qtGold': qtGold,
      'amigos': amigos,
      'avataresComprados': avataresComprados,
      'revolveresComprados': revolveresComprados, 
      'gamertag': gamertag,
      'currentAvatar': currentAvatar,
      'currentRevolver': currentRevolver
    };
  }

}
