import 'package:bang/main.dart';
import 'package:bang/pages/convitesAmizadePage.dart';
import 'package:bang/services/getUserInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';
import '../pages/bluetoothClientPage.dart';
import '../pages/rankingPage.dart';
import '../pages/duelOnlineMenu.dart';
import '../services/enviarConvites.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onlineWaitAnswerPage.dart';
import '../pages/onlineVersusPage.dart';
import '../services/enviarConvites.dart';
import '../pages/addAmigos.dart';
import 'dart:async';

class onlineMenuPage extends StatefulWidget {
  const onlineMenuPage({super.key});

  @override
  State<onlineMenuPage> createState() => _onlineMenuPageState();
}

class _onlineMenuPageState extends State<onlineMenuPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;
  bool temConviteNovo = false;
  StreamSubscription? _convitesSub;

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
    final userId = FirebaseAuth.instance.currentUser!.uid;

    pegarTodosDadosJogador(userId);

    ouvirConvites(userId, onConviteRecebido);
    _convitesSub = ouvirConvitesAmizade(userId, (conviteId, convite) {
      setState(() {
        temConviteNovo = true; // acende a bolinha verde
      });
    }) as StreamSubscription?;
  }

  void onConviteRecebido( String conviteId, Map<String, dynamic> convite, ) {
  
    final String uid = FirebaseAuth.instance.currentUser!.uid;

  showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      backgroundColor: Colors.transparent, // deixa transparente para ver o fundo
      contentPadding: EdgeInsets.zero, // remove padding extra
      content: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imgs/loginBG.png'), // sua imagem
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Convite Recebido',
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(
                  fontSize: 40,
                  height: 0.8,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50),
              Text(
                'Você recebeu um convite de ${convite['remetenteName']} para jogar. Aceita?',
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(
                  fontSize: 30,
                  height: 0.8,
                  color: const Color.fromARGB(207, 255, 255, 255),
                ),
              ),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async{
                      await rejeitarConvite(uid, conviteId);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Recusar',
                      style: GoogleFonts.vt323(
                        fontSize: 30,
                        height: 0.8,
                        color: const Color.fromARGB(255, 239, 4, 4),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async{
                      await aceitarConvite(uid, conviteId, convite, convite['remetenteId']);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DuelScreen(player1Uid: uid, player2Uid:convite['remetenteId'],)),
                      );
                    },
                    child: Text(
                      'Aceitar',
                      style: GoogleFonts.vt323(
                        fontSize: 30,
                        height: 0.8,
                        color: const Color.fromARGB(255, 177, 163, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
);
}

@override
  void dispose() {
    // TODO: implement dispose
     _convitesSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/imgs/bg_menu.png', fit: BoxFit.cover),
            ),
                Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));}, 
            style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
            child: Icon(Icons.arrow_back))),
             Positioned(
                top: 20,
                right: 20,
                child: Stack(
                  clipBehavior: Clip.none, // permite a bolinha sair do botão se quiser
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          temConviteNovo = false; // limpa quando entra na página
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (builder) => ConvitesAmizadePage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF544528),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Icon(Icons.person_add),
                    ),
                    if (temConviteNovo) // variável bool do estado
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color.fromARGB(255, 152, 249, 156), width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
  children: [
    // Texto com contorno (usando Paint)
    Text(
      'Online',
      textAlign: TextAlign.center,
      style: GoogleFonts.vt323(
        fontSize: 60,
        height: 0.8,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = Color(0xFF4A251D),
      ),
    ),
    // Texto preenchido
    Text(
      'Online',
      textAlign: TextAlign.center,
      style: GoogleFonts.vt323(
        fontSize: 60,
         height: 0.8,
        color: Color(0xFFE33117),
      ),
    ),
  ],
),
                  SizedBox(height: 50,),
                  SizedBox(
  width: 300, // define a largura padrão dos botões
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => OnlineDuelMenuPage()));
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF544528),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      'Duelo Online',
      style: GoogleFonts.vt323(
        fontSize: 40,
        fontStyle: FontStyle.italic,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    ),
  ),
),
              SizedBox(height: 20,),
                SizedBox(
                width: 300, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Rankingpage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ranking',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 20,),
                SizedBox(
                width: 300, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddAmigosPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Amigos',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}