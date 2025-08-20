import 'package:bang/main.dart';
import 'package:bang/pages/bluetoothPreparePage.dart';
import 'package:bang/pages/onlineWaitAnswerPage.dart';
import 'package:bang/pages/rankingMoreDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';
import '../services/getAmigos.dart';
import '../services/enviarConvites.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rankingpage extends StatefulWidget {
  const Rankingpage({super.key});

  @override
  State<Rankingpage> createState() => _RankingpageState();
}

class _RankingpageState extends State<Rankingpage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;
  List<Map<String, dynamic>> ranking = [];
  int _currentIndex = 0; // começa do zero
  final ScrollController _scrollController = ScrollController();

  

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

  void _scrollToMyPosition() {
  final myIndex = ranking.indexWhere(
      (player) => player['id'] == FirebaseAuth.instance.currentUser!.uid);
  if (myIndex != -1 && _scrollController.hasClients) {
    final itemHeight = 120.0;
    final offset = itemHeight * myIndex;

    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
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

  Future<void> _loadAmigos() async {
  // Se já carregou tudo, nem busca


  final amigosInfo = await getTodosData();
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
      ),
      "qtVitoria": amigo['qtVitoria'] ?? 0,
    }).toList();

      ranking = novos;

  });

  ranking.sort((a, b) {
  final bountyA = double.tryParse(a['bounty'] ?? '0') ?? 0;
  final bountyB = double.tryParse(b['bounty'] ?? '0') ?? 0;
  return bountyB.compareTo(bountyA);
});

WidgetsBinding.instance.addPostFrameCallback((_) {
  _scrollToMyPosition();
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
          Navigator.push(context, MaterialPageRoute(builder: (builder) => RankingMDpage(name: player['name']!, bounty: player['bounty']!, avatar: player['avatar'], duelosVencidos: player['qtVitoria'])));
        },
        
      );
    },
  ),
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