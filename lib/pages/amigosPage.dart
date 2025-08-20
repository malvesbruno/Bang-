import 'package:bang/main.dart';
import 'package:bang/pages/bluetoothPreparePage.dart';
import 'package:bang/pages/onlineWaitAnswerPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';
import '../services/getAmigos.dart';
import '../services/enviarConvites.dart';

class AmigosPage extends StatefulWidget {
  const AmigosPage({super.key});

  @override
  State<AmigosPage> createState() => _AmigosPageState();
}

class _AmigosPageState extends State<AmigosPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;
  List<Map<String, dynamic>> ranking = [];
  int _currentIndex = 0; // começa do zero
  final int _pageSize = 10; // quantos amigos por vez
  bool _hasMore = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    playin = AppData.mute == 0;
    _loadAmigos();
    /* ranking.sort((a, b) {
    int bountyA = int.parse(a['bounty']!);
    int bountyB = int.parse(b['bounty']!);
    return bountyB.compareTo(bountyA); // ordem decrescente
  }); */
  }

  String _getBounty(double qtVitoria, double qtDerrota, double qtEmpate){
    final base = 20;
    final v = qtVitoria;
  final d = qtDerrota;
  final e = qtEmpate;

  double bounty = base + (v * 250) - (d * 100) - (e * 50);
  bounty = bounty.clamp(0, 10000000); // mínimo 0, máximo 10 mil
  return "${bounty.toStringAsFixed(2)}";
  }

  Future<void> _loadAmigos({bool append = false}) async {
  // Se já carregou tudo, nem busca
  if (!_hasMore) return;

  print('Amigos' '${AppData.amigos.toString()}');

  final end = (_currentIndex + _pageSize) > AppData.amigos.length
      ? AppData.amigos.length
      : (_currentIndex + _pageSize);

  final chunk = AppData.amigos.sublist(_currentIndex, end);

  final amigosInfo = await getAmigosData(chunk);
  if (!mounted) return;
  setState(() {
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
      ranking.addAll(novos);
    } else {
      ranking = novos;
    }

    _currentIndex = end;
    _hasMore = _currentIndex < AppData.amigos.length;
  });

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
    // Texto com contorno (usando Paint)
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
    // Texto preenchido
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

      int stars;
      if (posPercent <= 0.10) {
        stars = 6;
      } else if (posPercent <= 0.50) {
        stars = 3;
      } else {
        stars = 1;
      }

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