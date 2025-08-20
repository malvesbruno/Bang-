import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../widgets/popUpFinal.dart';
import '../main.dart';
import '../appdata.dart';

class FinalDuelpage extends StatefulWidget{
  final Duration duracao; 
  final bool venceu;
  final bool empate;
  final bool sacouBT;
  final bool sacaramBT;
  final bool treino;

  const FinalDuelpage({super.key, required this.duracao, required this.venceu, required this.empate, required this.sacouBT, required this.sacaramBT, this.treino = false,});

   @override
  State<FinalDuelpage> createState() => _FinalDuelpageState();
}

class _FinalDuelpageState extends State<FinalDuelpage> with SingleTickerProviderStateMixin {
  final AudioPlayer audioPlayer = AudioPlayer();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _mostrarJanela = false;
  bool playin = AppData.mute == 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    iniciarSequencia();
  }

  void stopMusic() async{
    audioPlayer.stop();
    audioPlayer.dispose();
  }

  void iniciarSequencia() async {
    if(playin){
      if (!widget.treino) {
    if (widget.venceu || widget.sacaramBT){
      await audioPlayer.play(AssetSource("audio/win.mp3"));
    } else if(widget.sacouBT || !widget.venceu && !widget.empate){
      await audioPlayer.play(AssetSource("audio/loose.mp3"));
    } else if(widget.empate){
      await audioPlayer.play(AssetSource("audio/draw.mp3"));
    }
      } else{
        await audioPlayer.play(AssetSource("audio/win.mp3"));
      }
    }
    await Future.delayed(Duration(seconds: 2));

    setState(() => _mostrarJanela = true);
    _controller.forward(); // inicia o zoom
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.dispose();
  }

  Widget _getResultadoBg(){
    if (!widget.treino){
    if (widget.venceu || widget.sacaramBT){
      return Positioned.fill(
              child: Image.asset('assets/imgs/win.jpg', fit: BoxFit.cover),
            );
    } else if(widget.sacouBT && !widget.venceu && !widget.empate){
      return Positioned.fill(
              child: Image.asset('assets/imgs/youDraw.jpg', fit: BoxFit.cover),
            );
    } 
    
    else if(!widget.sacouBT || !widget.venceu && !widget.empate){
      return Positioned.fill(
              child: Image.asset('assets/imgs/loose.jpg', fit: BoxFit.cover),
            );
    } else {
      return Positioned.fill(
              child: Image.asset('assets/imgs/draw.jpg', fit: BoxFit.cover),
            );
    }
    } else{
      return Positioned.fill(
              child: Image.asset('assets/imgs/train.png', fit: BoxFit.cover),
            );
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _getResultadoBg(),
            if (_mostrarJanela)
              Center(
                child: FinalPopup(duracao: widget.duracao, venceu: widget.venceu, empate: widget.empate, sacaramBT: widget.sacaramBT, sacouBT: widget.sacouBT, onReturn: () => {
                  stopMusic(),

                  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MyHomePage()),
  )
                }, treino: widget.treino,
                )
                )
          ],
        ),
      ),
    );
  }
}
