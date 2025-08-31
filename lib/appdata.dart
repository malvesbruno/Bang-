import 'dart:convert';
import 'package:bang/models/revolverModel.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import '../models/avatarModel.dart';

// O AppData cuida de tudo que envolva dados do SQLite e do Shared_Preferences

class AppData {
  static const String jogadorIdKey = "jogador_unico_id";
  static String? _cachedId;

  static int mute = 0; // define se é pra tocar áudios ou não
  static int qtVitoria = 0; // quantidade vitória
  static int qtDerrota = 0; // quantidade Derrota
  static int qtEmpate = 0; // quantidade Empate
  static int qtGold = 0; // quantidade Gold
  static List<String> amigos = []; // lista de amigos
  static List<String> avataresComprados = ["assets/imgs/avatares/avatar1.png"]; //lista de Avatares Comprados
  static List<String> revolveresComprados = ["assets/imgs/revolvers/revolver1.png"]; // lista de Revolvers Comprados
  static String gamertag = ''; // gamertag
  static String currentAvatar = 'assets/imgs/avatares/avatar1.png'; // avatar atual
  static String currentRevolver = 'assets/imgs/revolvers/revolver1.png'; // revolver atual 


  // lista de revolveres 
  static List<Revolver> revolveres = [
    Revolver(name: 'Velho Fiel', avatarPath: 'assets/imgs/revolvers/revolver1.png', owned: true, price: 200,
     lore: 'Dizem que este revólver já esteve em mais mãos do que se pode contar. A madeira gasta da coronha guarda marcas de suor, sangue e poeira do deserto. Não é o mais rápido, nem o mais letal… mas nunca falhou em disparar quando necessário.'),
     Revolver(name: 'Estrela do Oeste', avatarPath: 'assets/imgs/revolvers/revolver2.png', owned: revolveresComprados.contains( 'assets/imgs/revolvers/revolver2.png'), price: 900,
     lore: 'Forjado por um armeiro que acreditava que cada tiro deveria alcançar os céus. Suas estrelas gravadas não são apenas ornamentos: contam-se histórias de que quem porta esta arma atira com a confiança dos xerifes lendários. Seu brilho polido desafia até o sol do deserto.'),
     Revolver(name: 'Aurora Dourada', avatarPath: 'assets/imgs/revolvers/revolver3.png', owned: revolveresComprados.contains( 'assets/imgs/revolvers/revolver3.png'), price: 1300,
     lore: 'Reza a lenda que este revólver foi entregue a um pistoleiro ao amanhecer, como pagamento por um duelo impossível. A coronha clara e o dourado reluzente carregam a promessa de um novo começo — mas também o peso de finais repentinos.'),
     Revolver(name: 'Crepúsculo Sombrio', avatarPath: 'assets/imgs/revolvers/revolver4.png', owned: revolveresComprados.contains( 'assets/imgs/revolvers/revolver4.png'), price: 1700,
     lore: 'Não brilha, não se exibe — apenas sussurra morte no cair da noite. O ouro escurecido reflete pouco, mas guarda histórias de duelos onde a vitória foi decidida antes mesmo do primeiro disparo. Alguns dizem que só aparece nas mãos de quem já tem sangue demais na consciência.'),
     Revolver(name: 'A Vingança do Além', avatarPath: 'assets/imgs/revolvers/revolver5.png', owned: revolveresComprados.contains( 'assets/imgs/revolvers/revolver5.png'), price: 2100,
     lore: """
Ninguém sabe ao certo quem foi o primeiro dono desta arma. Alguns dizem que pertenceu a um pistoleiro traído por seus próprios companheiros, outros juram que foi moldada a partir da alma de todos aqueles que tombaram injustamente na areia do deserto.

Sua forma é diferente de qualquer metal já visto: contornos brancos e um brilho azulado translúcido, como se a própria arma fosse feita de névoa congelada. Não há pólvora que a alimente, nem artesão que reivindique sua criação. Ela simplesmente aparece — na carroça de uma cigana, no coldre de um forasteiro ou esquecida em meio às dunas — sempre aguardando aquele que carrega dentro de si mais ódio do que vida.

Quem ousa empunhá-la sente o peso do silêncio, e alguns juram ouvir murmúrios vindo da arma. Murmúrios de vozes que exigem sangue, justiça ou vingança. A cada disparo, a lenda diz que um espírito encontra descanso… mas o portador paga o preço, pois a arma nunca se sacia totalmente.

No Oeste, contam que aquele que possui a Vingança do Além não escolhe seus duelos — é a própria arma que escolhe por ele."""),
  ];

  //lista de avatares
  static List<Avatar> avatares = [
    Avatar(name: 'o Homem sem Nome', avatarPath: 'assets/imgs/avatares/avatar1.png', owned: true, price: 200, 
    lore: 'Ninguém sabe de onde veio, nem pra onde vai. Carrega no olhar a frieza de quem já viu tudo, mas nunca fala sobre o passado. Alguns dizem que já foi fazendeiro, outros juram que era pistoleiro de aluguel. A única certeza é que ele chega, faz justiça à sua maneira e desaparece antes do pôr do sol.'),
    Avatar(name: 'O homem de preto', avatarPath: 'assets/imgs/avatares/avatar3.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar3.png') , price: 1200,
     lore: 'Chamado de "O Baladeiro do Oeste", ele carrega um violão gasto e duas pistolas. Canta canções sobre dor, perda e redenção antes dos duelos. Seu estilo sombrio e sua voz grave ecoam pelos desertos como maldição ou prece. Cada bala que dispara é como uma última nota de uma canção triste.'),
    Avatar(name: 'Mira de Prata', avatarPath: 'assets/imgs/avatares/avatar4.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar4.png') , price: 1600,
     lore: 'Desde pequena, derrubava garrafas com estilingue a dezenas de metros. Aos 12, já era considerada a melhor atiradora da região. Cresceu ouvindo que mulheres não tinham lugar no Oeste, mas cada duelo vencido provou o contrário. Hoje, “Mira de Prata” é conhecida como a mais jovem e mortal pistoleira.'),
    Avatar(name: 'Cachorro Urubu', avatarPath: 'assets/imgs/avatares/avatar5.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar5.png') , price: 2000,
     lore: 'Um andarilho excêntrico que mistura poesia, filosofia e pólvora. Usa roupas surradas, gargalha como um louco e cita versos enigmáticos. Alguns dizem que é profeta, outros que é só mais um bêbado. Mas quando sua pistola canta, não há poesia mais certeira que a sua bala. (“Eu devia estar contente…” — costuma murmurar antes dos tiros).'),
    Avatar(name: 'Madame Víbora', avatarPath: 'assets/imgs/avatares/avatar6.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar6.png') , price: 2400,
     lore: 'Dona do bordel mais famoso do Oeste. Atrás do charme, guarda segredos e um arsenal escondido. Sua cadeira e a shotgun são símbolos de poder: quem entra em seu salão respeita as regras ou sai carregado. Sedutora e cruel quando precisa, é temida tanto quanto amada.'),
    Avatar(name: 'Relâmpago do Deserto', avatarPath: 'assets/imgs/avatares/avatar7.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar7.png') , price: 2800,
     lore: 'Dizem que nasceu sobre a sela e nunca parou de cavalgar. Seu cavalo é tão rápido quanto o vento, e juntos são imparáveis. Em meio à poeira, ele atira sem errar, como se fosse um só com a montaria. Nenhum xerife conseguiu alcançá-lo.'),
    Avatar(name: 'Estrela Veloz', avatarPath: 'assets/imgs/avatares/avatar8.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar8.png') , price: 3200,
     lore: 'A melhor cavaleira do Oeste. Criada em terras selvagens, aprendeu a montar antes mesmo de andar. Seu cavalo é sua alma gêmea, e sua arma, uma extensão de suas mãos. Quando a poeira sobe no horizonte, todos sabem que “Estrela Veloz” está chegando.'),
    Avatar(name: 'Angel', avatarPath: 'assets/imgs/avatares/avatar2.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar2.png') , price:3600,
     lore: 'Conhecida como “o Anjo do Deserto”, sua beleza é tão desarmante quanto sua mira. Muitos a subestimam, achando que é apenas um rosto bonito — até que sentem o peso de sua justiça rápida. Seu sorriso guarda segredos, e dizem que quem cruza seu caminho nunca mais esquece a intensidade de seus olhos.'),
    Avatar(name: 'Viúva de Fogo', avatarPath: 'assets/imgs/avatares/avatar9.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar9.png') , price: 4000,
     lore: 'Depois de perder o marido em uma emboscada, jurou vingança. Desde então, caça cada bandido que cruza seu caminho, sem piedade. Usa um sobretudo de couro que pertencia a ele, e a cada bala disparada sente que se aproxima da redenção. O Oeste a teme, mas ninguém ousa enfrentá-la de frente.'),
    Avatar(name: 'Última Sombra', avatarPath: 'assets/imgs/avatares/avatar10.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar10.png') , price: 4400,
     lore: 'Um cowboy solitário que sempre parte antes do amanhecer. Nunca fica em uma cidade por muito tempo, como se carregasse um destino que não pode compartilhar. Muitos acreditam que ele está condenado a vagar sem descanso, andando sempre em direção ao horizonte. É lembrado apenas como uma sombra que se afasta.'),
    Avatar(name: 'O Homem Estranho', avatarPath: 'assets/imgs/avatares/avatar11.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar11.png') , price: 4800,
     lore: """Ninguém sabe se ele nasceu de uma mãe ou se foi parido pelas sombras do deserto. Alguns juram que já o viram em batalhas antigas, outros dizem que ele é eterno, vagando sem nunca envelhecer. Sua figura é sempre a mesma: um homem encoberto, olhos brilhando como carvões acesos, cavalgando uma montaria igualmente espectral.

Não fala. Não precisa. O som de seus cascos é suficiente para gelar o sangue dos mais bravos. Onde o Homem Estranho aparece, a vida definha: colheitas secam, gado some, e os homens caem mortos sem que se saiba de quê. É como se a própria terra rejeitasse sua presença.

Alguns acreditam que ele é a Morte em carne e osso, vagando em busca de almas perdidas. Outros, que é um pistoleiro condenado, amaldiçoado a cavalgar até que o Oeste não seja mais nada além de pó. Há até quem diga que ele surge quando o equilíbrio é quebrado, como prenúncio de guerras ou tragédias.

Ninguém nunca sobreviveu a um duelo contra ele — e os poucos que afirmam tê-lo visto de perto carregam cicatrizes na alma, não no corpo.

No Oeste, seu nome não é dito em voz alta. Só o chamam de uma coisa:
O Homem Estranho."""),
    Avatar(name: 'Águia Caindo', avatarPath: 'assets/imgs/avatares/avatar12.png', owned: avataresComprados.contains( 'assets/imgs/avatares/avatar12.png') , price: 5200,
     lore: """Dizem que ele não é apenas um homem, mas o espírito de um cacique ancestral que voltou para proteger as terras do Oeste. Monta sempre com a dignidade de um rei e o silêncio de um fantasma. Seu nome vem de uma visão: uma águia flamejante que caía dos céus para se sacrificar e proteger seu povo.

Reza a lenda que, quando os ventos mudam e a poeira cobre o horizonte, o Águia Caindo aparece. Seu cavalo pisa leve como se não fosse deste mundo, e seus olhos refletem o fogo da águia celestial. Uns acreditam que ele é um guardião enviado para manter o equilíbrio entre a destruição dos pistoleiros e a vida que ainda resiste. Outros sussurram que ele é a última esperança contra a escuridão que se espalha no deserto.

No Oeste, onde morte e pólvora reinam, poucos são temidos… mas só um é reverenciado como protetor e maldição ao mesmo tempo: o Águia Caindo"""),
  ];

  //pega o id do jogador
  static Future<String> getJogadorId() async {
    if (_cachedId != null) return _cachedId!;

    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(jogadorIdKey);

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(jogadorIdKey, id);
    }

    _cachedId = id;
    return id;
  }

  // inicia o jogador buscando dados no SQLite e se não houver cria os dados
  static Future<void> initJogador() async {
    final id = await getJogadorId();
    final db = await DBHelper.database;
    final result = await db.query('jogador', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      await db.insert('jogador', {
        'id': id,
        'mute': 0,
        'qtVitoria': 0,
        'qtDerrota': 0,
        'qtEmpate': 0,
        'qtGold': 100000,
        'amigos': jsonEncode([]),
        'avataresComprados': jsonEncode([]),
        'revolveresComprados': jsonEncode([]),
        'gamertag': '',
        'avatar': 'assets/imgs/avatares/avatar1.png',
        'revolver': 'assets/imgs/revolvers/revolver1.png',
      });
    }

    final data = await db.query('jogador', where: 'id = ?', whereArgs: [id]);

  if (data.isNotEmpty) {
    final jogador = data.first;
    mute = int.tryParse(jogador['mute']?.toString() ?? '0') ?? 0;
    qtVitoria = int.tryParse(jogador['qtVitoria']?.toString() ?? '0') ?? 0;
    qtDerrota = int.tryParse(jogador['qtDerrota']?.toString() ?? '0') ?? 0;
    qtEmpate = int.tryParse(jogador['qtEmpate']?.toString() ?? '0') ?? 0;
    qtGold = int.tryParse(jogador['qtGold']?.toString() ?? '0') ?? 0;
    amigos = List<String>.from(jsonDecode(jogador['amigos']?.toString() ?? '[]'));
    avataresComprados = List<String>.from(jsonDecode(jogador['avataresComprados']?.toString() ?? '["assets/imgs/avatares/avatar1.png"]'));
    revolveresComprados = List<String>.from(jsonDecode(jogador['revolveresComprados']?.toString() ?? '["assets/imgs/revolvers/revolver1.png"]'));
    gamertag = jogador['gamertag']?.toString() ??'';
    currentAvatar = jogador['avatar']?.toString() ?? 'assets/imgs/avatares/avatar1.png';
    currentRevolver = jogador['revolver']?.toString() ?? 'assets/imgs/revolvers/revolver1.png';
    
  }
  }

  // salva as informações do user
  static Future<void> salvartudo() async {
  final db = await DBHelper.database;
  await db.update(
    'jogador',
    {
      'qtVitoria': qtVitoria,
      'qtDerrota': qtDerrota,
      'qtEmpate': qtEmpate,
      'qtGold': qtGold,
      'amigos': jsonEncode(amigos),
      'avataresComprados': jsonEncode(avataresComprados),
      'revolveresComprados': jsonEncode(revolveresComprados),
      'gamertag': gamertag,
      'avatar': currentAvatar,
      'revolver': currentRevolver,


    },
    where: 'id = ?',
    whereArgs: [await getJogadorId()],
  );
}

  // salvar estatísticas
  static Future<void> salvarEstatisticas() async {
  final db = await DBHelper.database;
  await db.update(
    'jogador',
    {
      'qtVitoria': qtVitoria,
      'qtDerrota': qtDerrota,
      'qtEmpate': qtEmpate,
    },
    where: 'id = ?',
    whereArgs: [await getJogadorId()],
  );
}

// salva a gamertag
static Future<void> salvarGamertag() async {
  final db = await DBHelper.database;
  await db.update(
    'jogador',
    {
      'gamertag': gamertag,
    },
    where: 'id = ?',
    whereArgs: [await getJogadorId()],
  );
}



  //pega os dados do jogador
  static Future<Map<String, dynamic>?> getJogadorData() async {
    final id = await getJogadorId();
    final db = await DBHelper.database;
    final result = await db.query('jogador', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> toggleMute() async {
    final data = await getJogadorData();
    if (data != null) {
      final novoMute = data['mute'] == 1 ? 0 : 1;
      await DBHelper.insert('jogador', {
        ...data,
        'mute': novoMute,
      });
    }
  }

  // Adiciona uma vitória ao banco
  static Future<void> adicionarVitoria() async {
    final data = await getJogadorData();
    if (data != null) {
      int vitorias = data['qtVitoria'] ?? 0;
      await DBHelper.insert('jogador', {
        ...data,
        'qtVitoria': vitorias + 1,
      });
    }
  }

  // Outras funções semelhantes para derrota, empate, gold etc.
}
