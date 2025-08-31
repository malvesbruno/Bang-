import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';

// pagina que mostra o revolver recém comprado
class ComprarRevolverpage extends StatefulWidget {
  final String name;
  final String avatar;

  const ComprarRevolverpage({super.key, required this.name, required this.avatar});

  @override
  State<ComprarRevolverpage> createState() => _ComprarRevolverpageState();
}

class _ComprarRevolverpageState extends State<ComprarRevolverpage> {
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
  gradient: widget.name == 'A Vingança do Além'
      ? RadialGradient(
          colors: [
            const Color.fromARGB(255, 89, 115, 137).withOpacity(0.6),
            const Color.fromARGB(255, 7, 41, 92).withOpacity(0.8),
            Colors.black,
          ],
          stops: [0.0, 0.5, 1.0],
          center: Alignment.center,
          radius: 1.0,
        )
      : RadialGradient(
          colors: [
            const Color.fromARGB(57, 255, 255, 255).withOpacity(0.2),
            const Color.fromARGB(253, 34, 34, 34).withOpacity(0.4),
            Color.fromARGB(255, 0, 0, 0),
          ],
          stops: [0.2, 0.5, 1.0],
          center: Alignment.center,
          radius: 1.0,
        ),
  color: widget.name != 'A Vingança do Além' ? Color(0xFFDDD7CC) : null,
  border: Border.all(color: Colors.brown.shade900, width: 2),
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
                    color: Color.fromARGB(255, 255, 255, 255),
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