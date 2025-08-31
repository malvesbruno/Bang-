import 'package:bang/pages/bluetoothLobbyPage.dart';
import 'package:bang/pages/catalog_menu.dart';
import 'package:bang/pages/rankingMoreDetailPage.dart';
import 'package:bang/pages/treinoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';
import '../pages/tutorialPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/bluetooth_permission.dart';
import '../pages/onlineMenu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/logInPage.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // garante que todas as dependencias foram iniciadas
  await Firebase.initializeApp(); // inicia a biblioteca do banco de dados
  await AppData.initJogador(); // inicia o jogador ou cria se ainda não existir


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AudioPlayer audioPlayer = AudioPlayer(); // Variável que toca os áudios
  bool playin = AppData.mute == 0; // váriavel define se o audio vai tocar


  // calcula o preço na cabeça do jogador
  String _getBounty(double qtVitoria, double qtDerrota, double qtEmpate){
    final base = 20;
    final v = qtVitoria;
  final d = qtDerrota;
  final e = qtEmpate;

  double bounty = base + (v * 250) - (d * 100) - (e * 50);
  bounty = bounty.clamp(0, 10000000); // mínimo 0, máximo 10 mil
  return "${bounty.toStringAsFixed(2)}";
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // deixa a tela em pé
    BluetoothPermission.requestBluetoothPermissions();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    playin = AppData.mute == 0; // váriavel define se o audio vai tocar
  if (playin) {
    audioPlayer.setReleaseMode(ReleaseMode.loop);  // mantém o player em loop
    audioPlayer.play(AssetSource('audio/menu.mp3')); // toca o áudio
  }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: 
          Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/imgs/bg_menu.png', fit: BoxFit.cover),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: 
              GestureDetector(onTap: (){
                showDialog(
  context: context,
  builder: (context) {
    return Dialog(
  backgroundColor: Colors.transparent, // transparente para ver o fundo
  insetPadding: EdgeInsets.zero, // remove o padding padrão do Dialog
  child: Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height / 1.5, // largura total da tela
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/imgs/avatarLoja.png'), // sua imagem
        fit: BoxFit.fill,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ou max se quiser ocupar verticalmente também
        children: [
          SizedBox(height: 120,),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (builder) => RankingMDpage(name: AppData.gamertag, bounty: _getBounty(AppData.qtVitoria.toDouble(), AppData.qtDerrota.toDouble(), AppData.qtEmpate.toDouble()), avatar: AppData.currentAvatar, duelosVencidos: AppData.qtVitoria)));
            },
            child: Column(children: [
             SizedBox(
                  width: 150, // ou 40, ou o que você quiser
                  height: 150,
                  child: SizedBox(
            width: 80,
            height: 80,
            child: Container(
              width: 80, // largura do avatar + borda
              height: 80, // altura do avatar + borda
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF544528), // cor da borda
                  width: 2.5, // espessura da borda
                ),
              ),
              child: CircleAvatar(
                radius: 36, // tamanho do avatar (80 / 2 - 4 de borda)
                backgroundColor: Color.fromARGB(255, 251, 230, 218),
                backgroundImage: AssetImage(AppData.currentAvatar),
              ),
            )
          ),),
          SizedBox(height: 20),
          Text(
            AppData.gamertag,
            textAlign: TextAlign.center,
            style: GoogleFonts.vt323(
              fontSize: 30,
              height: 0.8,
              color: const Color.fromARGB(207, 255, 255, 255),
            ),
          ),

          ],),),
          SizedBox(height: 35),
          SizedBox(
                width: 250, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                    audioPlayer.stop();
                    audioPlayer.dispose();
                    Navigator.push(context, MaterialPageRoute(builder: (builder) => CatalogMenuPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.shopping_cart, size: 30,),
                      Spacer(),
                      Text(
                    'loja',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer()
                    ]
                  ),
                  
                ),
              ),
        ],
      ),
    ),
  ),
);
  },
);
              },
              child: 
              SizedBox(
                  width: 60, // ou 40, ou o que você quiser
                  height: 60,
                  child: SizedBox(
            width: 80,
            height: 80,
            child: Container(
  width: 80, // largura do avatar + borda
  height: 80, // altura do avatar + borda
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: Color(0xFF544528), // cor da borda
      width: 2.5, // espessura da borda
    ),
  ),
  child: CircleAvatar(
    radius: 36, // tamanho do avatar (80 / 2 - 4 de borda)
    backgroundColor: Color.fromARGB(255, 251, 230, 218),
    backgroundImage: AssetImage(AppData.currentAvatar),
  ),
)
          ),)
                ),
              ),
            Positioned(
              right: 20,
              top: 20,
              child: 
              ElevatedButton(
                  onPressed: () {
                    setState(() {
    playin = !playin;

    if (playin) {
      audioPlayer.play(AssetSource('audio/menu.mp3'));
    } else {
      audioPlayer.stop();
      // NÃO chama dispose aqui, senão perde o controle depois
    }

    AppData.mute = !playin ? 1 : 0;
    AppData.toggleMute(); // Se quiser salvar globalmente
  });
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: SizedBox(
                  width: 30, // ou 40, ou o que você quiser
                  height: 30,
                  child: playin? Image.asset(
                    'assets/imgs/sound.png',
                    fit: BoxFit.cover, // ou cover, se quiser que ela preencha
                  ) : Image.asset(
                    'assets/imgs/mute.png',
                    fit: BoxFit.cover, // ou cover, se quiser que ela preencha
                  ),
                ),
                ),),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/imgs/logo.png", height:200,),
                  SizedBox(
  width: 250, // define a largura padrão dos botões
  child: ElevatedButton(
    onPressed: () {
      audioPlayer.stop();
      audioPlayer.dispose();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => onlineMenuPage()));
      } else{
        Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage()));
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF544528),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      'online',
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
                width: 250, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                    audioPlayer.stop();
                    audioPlayer.dispose();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothLobbyPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'offline',
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
                width: 250, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                    audioPlayer.stop();
                    audioPlayer.dispose();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TreinoDuelPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'treino',
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
                    width: 250, // define a largura padrão dos botões
                    child: ElevatedButton(
                      onPressed: () { 
                       Navigator.push(context, MaterialPageRoute(builder: (context) => Tutorialpage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF544528),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'tutorial',
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
                  width: 250, // define a largura padrão dos botões
                  child: ElevatedButton(
                    onPressed: () async {
  final Uri url = Uri.parse('https://open.spotify.com/playlist/26oMoT6xjs8PFBHIJHkhJB?si=160fbbb070d4442c');

          try {
              await launchUrl(url, mode: LaunchMode.platformDefault);
            } catch (e) {
              print('Erro ao abrir a URL: $e');
            }
},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF544528),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'playlist',
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


