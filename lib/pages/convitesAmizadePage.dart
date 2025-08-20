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
import 'package:firebase_auth/firebase_auth.dart';

class ConvitesAmizadePage extends StatefulWidget {
  const ConvitesAmizadePage({super.key});

  @override
  State<ConvitesAmizadePage> createState() => _ConvitesAmizadePageState();
}

class _ConvitesAmizadePageState extends State<ConvitesAmizadePage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;
  List<Map<String, dynamic>> convites = [];
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


  Future<void> _loadAmigos() async {
  // Se já carregou tudo, nem busca

  final userId = FirebaseAuth.instance.currentUser!.uid;
  final amigosInfo = await getAllConvitesAmizade(userId);
  print(amigosInfo);
  setState(() {
    convites = amigosInfo.map((el) => {
      "id": el['id'],
      "remetenteId": el['remetenteId'],
      "name": el['remetenteName']
    }).toList();
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
    SizedBox(height: 50,),
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
    itemCount: convites.length,
    itemBuilder: (context, index) {
      final player = convites[index];

      return customListTile(
        name: player['name']!,
        remetenteId: player['remetenteId']!,
        aceitar: () async{
          final userId = FirebaseAuth.instance.currentUser!.uid;
          await aceitarConviteAmizade(userId, player['id'], player['remetenteId']);
        },
        rejeitar: () async{
          final userId = FirebaseAuth.instance.currentUser!.uid;
          await rejeitarConviteAmizade(userId, player['id']);
        }
        
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
  required String name,
  required String remetenteId,  // novo parâmetro
  VoidCallback? aceitar,
  VoidCallback? rejeitar,
}) {
  return  Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF544528),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Você recebeu um convite de amizade de",
                  style: GoogleFonts.vt323(
                    fontSize: 15,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    height: 0.8,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.vt323(
                    fontSize: 40,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    height: 0.8,
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Spacer(),
                    ElevatedButton(onPressed: rejeitar, 
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B3B2A),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                child: Text(
            'Rejeitar',
            style: TextStyle(
                      fontFamily: 'PirataOne',
                      fontSize: 18,
                      color: Color.fromARGB(255, 199, 66, 66).withOpacity(0.9),
                    ),
          )),
          Spacer(),
          ElevatedButton(onPressed: aceitar, 
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B3B2A),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                child: Text(
            'Aceitar',
            style: TextStyle(
                      fontFamily: 'PirataOne',
                      fontSize: 18,
                      color: Color(0xFFC19A6B).withOpacity(0.9),
                    ),
          )) ,
          Spacer(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
}