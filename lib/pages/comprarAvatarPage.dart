import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';

// pagina que mostra o avatar recém comprado
class ComprarAvatarpage extends StatefulWidget {
  final String name;
  final String avatar;

  const ComprarAvatarpage({super.key, required this.name, required this.avatar});

  @override
  State<ComprarAvatarpage> createState() => _ComprarAvatarpageState();
}

class _ComprarAvatarpageState extends State<ComprarAvatarpage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;

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

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: Stack(
    children: [
      Positioned.fill(
        child: Image.asset('assets/imgs/loginBG.png', fit: BoxFit.cover),
      ),
      Positioned.fill(
  child: Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/imgs/wantedFrame.png',),
        repeat: ImageRepeat.noRepeat,
        fit: BoxFit.contain, // ou BoxFit.fill
      ),
    ),
    child: Column(
      children: [
        SizedBox(height: 240),
        Image.asset(widget.avatar, height: 250,),
        SizedBox(height: 60,),
        Text(
                  widget.name,
                  style: GoogleFonts.vt323(
                    fontSize: 30,
                    color: Color(0xFF544528),
                    height: 0.8,
                  ),
                ),
                SizedBox(height: 30,),
                SizedBox(
                width: 200, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () async{
                  Navigator.pop(context);
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                    'voltar',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                    ]
                  ),
                  
                ),
              ),
        
      ],
    ),
  ),
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
            child: Icon(Icons.arrow_back))),
    ],
  ),
);

  }
}