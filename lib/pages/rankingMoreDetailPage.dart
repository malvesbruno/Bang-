import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';

// mostrar mais informações do user do ranking
class RankingMDpage extends StatefulWidget {
  final String name; // nome do user
  final String bounty; // valor do user
  final String avatar; // avatar do user
  final int duelosVencidos; // duelos vencidos pelo user

  const RankingMDpage({super.key, required this.name, required this.bounty, required this.avatar, required this.duelosVencidos});

  @override
  State<RankingMDpage> createState() => _RankingpageState();
}

class _RankingpageState extends State<RankingMDpage> {
  final AudioPlayer audioPlayer = AudioPlayer(); // variável que toca o audio
  bool playin = AppData.mute == 0; // define se pode tocar o audio

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    playin = AppData.mute == 0; // define se pode tocar o audio

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
                    fontSize: 40,
                    color: Color(0xFF544528),
                    height: 0.8,
                  ),
                ),
                SizedBox(height: 10,),
        Text(
                  '\$${widget.bounty}',
                  style: GoogleFonts.vt323(
                    fontSize: 30,
                    color: Color(0xFF544528),
                    height: 0.8,
                  ),
                ),
                SizedBox(height: 10,),
        Text(
                  'duelos vencidos: ${widget.duelosVencidos}',
                  style: GoogleFonts.vt323(
                    fontSize: 30,
                    color: Color(0xFF544528),
                    height: 0.8,
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