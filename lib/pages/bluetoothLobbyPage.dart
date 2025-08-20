import 'package:bang/main.dart';
import 'package:flutter/material.dart';
import '../pages/playingPage.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';
import '../pages/bluetoothHostPage.dart';
import '../pages/bluetoothClientPage.dart';

class BluetoothLobbyPage extends StatefulWidget {
  const BluetoothLobbyPage({super.key});

  @override
  State<BluetoothLobbyPage> createState() => _BluetoothLobbyPageState();
}

class _BluetoothLobbyPageState extends State<BluetoothLobbyPage> {
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
  children: [
    // Texto com contorno (usando Paint)
    Text(
      'Duelo por Bluetooth',
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
      'Duelo por Bluetooth',
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
      Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothHostPage()));
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF544528),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      'Hostear duelo',
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothClientPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Entrar em duelo',
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