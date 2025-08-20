import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../appdata.dart';




class Tutorialpage extends StatefulWidget {
  const Tutorialpage({super.key});

  @override
  State<Tutorialpage> createState() => _TutorialpageState();
}

class _TutorialpageState extends State<Tutorialpage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;


  @override
  void initState() {
    super.initState();
    // Força a orientação para paisagem (landscape)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return;
  }


  @override
  void dispose() {
    // Restaura as orientações permitidas ao sair da tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
              child: Image.asset('assets/imgs/tutorial.png', fit: BoxFit.cover),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton(onPressed: (){Navigator.pop(context);}, 
            style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
            child: Icon(Icons.arrow_back)))
          ],
        ),
      ),
    );
  }
}
