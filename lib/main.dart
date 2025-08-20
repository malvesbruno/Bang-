import 'package:bang/pages/bluetoothLobbyPage.dart';
import 'package:bang/pages/offlinePage.dart';
import 'package:bang/pages/treinoPage.dart';
import 'package:flutter/material.dart';
import '../pages/playingPage.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AppData.initJogador();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    BluetoothPermission.requestBluetoothPermissions();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    playin = AppData.mute == 0;
  if (playin) {
    audioPlayer.setReleaseMode(ReleaseMode.loop); 
    audioPlayer.play(AssetSource('audio/menu.mp3'));
  }
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
