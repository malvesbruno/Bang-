import 'package:bang/pages/onlineWaitAnswerPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';
import '../services/getAmigos.dart';
import '../services/nuvem.dart';


//Página mostrar todos os amigos do user
class AmigosPage extends StatefulWidget {
  const AmigosPage({super.key});

  @override
  State<AmigosPage> createState() => _AmigosPageState();
}

class _AmigosPageState extends State<AmigosPage> {
  final AudioPlayer audioPlayer = AudioPlayer(); //cria a variavel AudioPlayer que é usada para tocar sons 
  bool playin = AppData.mute == 0; // a variável playin determina se o audio vai tocar ou não
  List<Map<String, dynamic>> ranking = []; // lista de ranking que vai ser alimentada posteriormente 
  int _currentIndex = 0; // começa do zero
  final int _pageSize = 10; // quantos amigos por vez
  bool _hasMore = true; // variável que define se há mais amigos além dos mostrados na tela

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // determina que a tela do ceular fique de pé
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // a variável playin determina se o audio vai tocar ou não
    playin = AppData.mute == 0;
    // carrega todos os amigos do user
    _loadAmigos();
  }

  // função que realiza o calculo para determinar o preço na cabeça do amigo
  String _getBounty(double qtVitoria, double qtDerrota, double qtEmpate){
    final base = 20; // base 20 para que não seja possível ter uma bounty abaixo de 20
    final v = qtVitoria;
  final d = qtDerrota;
  final e = qtEmpate;

  // o preço é igual à base mais as vitórias multiplicadas 250 menos as derrotas multiplicadas por 100 menos os empates multiplicados por 50
  // assim criamos um sistema que não se torna muito fácil, aumentando a atesão
  double bounty = base + (v * 250) - (d * 100) - (e * 50);
  bounty = bounty.clamp(0, 10000000); // mínimo 0, máximo 10 mil
  return "${bounty.toStringAsFixed(2)}"; // retorna em um string com dois números depois da virgula. Similar à comos usamos com dinheiro
  }

  Future<void> _loadAmigos({bool append = false}) async {
  // Se já carregou tudo, nem busca
  if (!_hasMore) return;

  // se o index atual mais a quantidade carregada agora não for maior que a lista de amigos, o final é igual ao index atual + a quantidade carregada
  final end = (_currentIndex + _pageSize) > AppData.amigos.length
      ? AppData.amigos.length
      : (_currentIndex + _pageSize);

  // define a porção de amigos que são selecionados por vez
  final chunk = AppData.amigos.sublist(_currentIndex, end);

  // pega a porção dos amigos salvos no banco 
  final amigosInfo = await getAmigosData(chunk);
  if (!mounted) return;
  setState(() {
    //cria uma variável com as informações do amigo que posteriormente será adicionados à lista
    final novos = amigosInfo.map((amigo) => {
      "id": amigo['id'],
      "name": amigo['gamertag']?.toString() ?? "Sem nome",
      "avatar": amigo['currentAvatar']?.toString() ??
          'assets/imgs/avatares/avatar1_pose1.png',
      "bounty": _getBounty(
        (amigo['qtVitoria'] ?? 0).toDouble(),
        (amigo['qtDerrota'] ?? 0).toDouble(),
        (amigo['qtEmpate'] ?? 0).toDouble(),
      )
    }).toList();

    if (append) {
      // se há mais user do que a porção ele só adiciona ao ranking
      ranking.addAll(novos);
    } else {
      // se não, ele passa essa lista para o ranking
      ranking = novos;
    }
    // o index atual passa a ser o final
    _currentIndex = end;
    // define se há mais, verificando se o index atual é menor que o tamanho da lista 
    _hasMore = _currentIndex < AppData.amigos.length;
  });

  //retorna o ranking arrumado do maior para o menor
  ranking.sort((a, b) {
  final bountyA = double.tryParse(a['bounty'] ?? '0') ?? 0;
  final bountyB = double.tryParse(b['bounty'] ?? '0') ?? 0;
  return bountyB.compareTo(bountyA);
});
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: Stack(
    children: [
      Positioned.fill(
        child: Image.asset('assets/imgs/ranking_table.png', fit: BoxFit.cover),
      ),
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imgs/loginBG.png'),
            repeat: ImageRepeat.repeatY,
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Botão voltar
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF544528),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
              Center(
                child:  Stack(
  children: [
    Text(
      'Selecione um Amigo',
      textAlign: TextAlign.center,
      style: GoogleFonts.vt323(
        fontSize: 40,
        height: 0.8,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = Color(0xFF4A251D),
      ),
    ),
    Text(
      'Selecione um Amigo',
      textAlign: TextAlign.center,
      style: GoogleFonts.vt323(
        fontSize: 40,
         height: 0.8,
        color: Color(0xFFE33117),
      ),
    ),
  ],
),
              ),

              const SizedBox(height: 10),

              // Lista expandida para ocupar o restante da tela
              Expanded(
  child: ListView.builder(
    itemCount: ranking.length,
    itemBuilder: (context, index) {
      final player = ranking[index];
      int total = ranking.length;
      double posPercent = (index + 1) / total; // posição percentual (1-based)

      // define a periculosidade do user através da posição dele no ranking
      int stars;
      if (posPercent <= 0.10) {
        stars = 6;
      } else if (posPercent <= 0.50) {
        stars = 3;
      } else {
        stars = 1;
      }
      // cria um modelo de elemento para os resultados 
      return customListTile(
        avatarPath: player['avatar']!,
        name: player['name']!,
        bounty: player['bounty']!,
        stars: stars,
        onTap: () async{
          String conviteId = await enviarConvite(player['id']);
          Navigator.push(context, MaterialPageRoute(builder: (builder) => Onlinewaitanswerpage(conviteId: conviteId, amigoId: player['id'])));
        },
        
      );
    },
  ),
),
if (_hasMore)
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: 
    SizedBox(
      width: 300,
      child: ElevatedButton(
      onPressed: () {
        _loadAmigos(append: true);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF544528),
        foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      ),
      child: Text(
                  'Carregar mais',
                  style: GoogleFonts.vt323(
                    fontSize: 30,
                    color: Color.fromARGB(255, 255, 255, 255),
                    height: 0.8,
                  ),
                ),
    ),
    )
    
  ),
            ],
          ),
        ),
      )
    ],
  ),
);

  }
}

Widget customListTile({
  required String avatarPath,
  required String name,
  required String bounty,
  required int stars,  // novo parâmetro
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF544528),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Color.fromARGB(255, 251, 230, 218),
              backgroundImage: AssetImage(avatarPath),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.vt323(
                    fontSize: 40,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    height: 0.8,
                  ),
                ),
                Text(
                  "\$${bounty}",
                  style: GoogleFonts.vt323(
                    fontSize: 30,
                    color: const Color.fromARGB(221, 255, 255, 255),
                    height: 1,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: List.generate(stars, (index) => Icon(
                    Icons.star,
                    color: Colors.yellow[700],
                    size: 24,
                  )),
                ),
                SizedBox(height: 8,),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}