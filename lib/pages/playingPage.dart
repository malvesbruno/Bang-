import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../services/motion_service.dart';
import '../pages/finishDuelPage.dart';
import '../appdata.dart';




class PlayingPage extends StatefulWidget {
  final Function(Duration)? onReacaoFinalizada; 
  final bool treino;
  const PlayingPage({super.key, this.onReacaoFinalizada, this.treino = false});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  bool _sacado = false;
  bool _mostrarFire = false;
  bool _podeSacar = false;
  late DateTime _inicioTempoDeReacao;
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer audioPlayerDuel = AudioPlayer();
  bool playin = AppData.mute == 0;



  void iniciarSequenciaSonora() async {
    audioPlayer.setVolume(1);
     await audioPlayer.setAudioContext(AudioContext(
  android: AudioContextAndroid(
    isSpeakerphoneOn: false,
    stayAwake: false,
    contentType: AndroidContentType.music,
    usageType: AndroidUsageType.media,
    audioFocus: AndroidAudioFocus.gainTransientMayDuck, // Isso evita pegar foco exclusivo
  ),
));
  await audioPlayer.play(AssetSource("audio/countdown.mp3"));
  audioPlayerDuel.setVolume(0.1);
  if (playin){
  await audioPlayerDuel.play(AssetSource("audio/duel.mp3"));
  }
  await Future.delayed(Duration(milliseconds: 6000));
  if (!mounted) return;
setState(() {
  _podeSacar = true;
  _inicioTempoDeReacao = DateTime.now(); // ⏱️ Marca o tempo do sinal
});

}


  @override
  void initState() {
    super.initState();
    // Força a orientação para paisagem (landscape)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    iniciarSequenciaSonora();

    MotionService().startListening(onSaque: () async {
  if (!_podeSacar || _sacado) {
    if(!_podeSacar){
      await audioPlayer.stop();
  await audioPlayerDuel.stop();
      widget.onReacaoFinalizada?.call(Duration(milliseconds: 0));
    return;
  }
  }

  setState(() {
    _sacado = true;
    _mostrarFire = true;
  });

  final duracaoReacao = DateTime.now().difference(_inicioTempoDeReacao);

  await audioPlayer.play(AssetSource("audio/shot.mp3"));

  Future.delayed(Duration(seconds: 1), () {
    if (mounted) {
      setState(() {
        _mostrarFire = false;
      });
    }
  });
  if (!widget.treino){
  await Future.delayed(Duration(milliseconds: 1000));
  await audioPlayer.play(AssetSource("audio/dyingCough.mp3"));
  } else{
    await Future.delayed(Duration(milliseconds: 300));
  await audioPlayer.play(AssetSource("audio/glassBroken.mp3"));
  }
  await Future.delayed(Duration(milliseconds: 1500));
  await audioPlayer.stop();
  await audioPlayerDuel.stop();
  audioPlayer.dispose();
  audioPlayerDuel.dispose();

  if (!mounted) return;

    widget.onReacaoFinalizada?.call(duracaoReacao);
 
});

  }

  @override
  void dispose() {
    // Restaura as orientações permitidas ao sair da tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
    return widget.treino || _sacado ; // permite voltar se treino estiver ativo
  },
    child: Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Tamanhos relativos
          final revolverWidth = screenWidth * 1;
          final revolverHeight = revolverWidth * 0.55;

          return Stack(
            children: [
              // Fundo
              Positioned.fill(
                child: _sacado ? Image.asset(
                  'assets/imgs/bg.png', // imagem do deserto
                  fit: BoxFit.cover,
                ) : Image.asset(
                  'assets/imgs/bg_coldre.png', // coldre
                  fit: BoxFit.cover,
                ),
              ),

              // Coldre (por baixo)
            Positioned(
              bottom: screenHeight * 0.001,
              left: screenWidth * 0.001,
              width: revolverWidth,
              height: revolverHeight,
              child: AnimatedOpacity(
                opacity: _sacado ? 0.0 : 1.0,
                duration: Duration(milliseconds: 200),
                child: Image.asset(
                  'assets/imgs/revolver.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.001,
              left: screenWidth * 0.001,
              width: revolverWidth,
              height: revolverHeight,
              child: AnimatedOpacity(
                opacity: _sacado ? 0.0 : 1.0,
                duration: Duration(milliseconds: 200),
                child: Image.asset(
                  'assets/imgs/coldre.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

// Revólver
Positioned(
  bottom: screenHeight * 0.001,
  left: screenWidth * 0.001,
  width: revolverWidth,
  height: revolverHeight,
  child: AnimatedOpacity(
    opacity: _sacado ? 1.0 : 0.0,
    duration: Duration(milliseconds: 200),
    child: Image.asset(
      'assets/imgs/revolver.png',
      fit: BoxFit.contain,
    ),
  ),
),

              if (_mostrarFire)
              Positioned(
                bottom: screenHeight * 0.001 + revolverHeight / 24,
                left: screenHeight * 0.001 + revolverWidth / 1.78,
                width: revolverWidth * 1,
                height: revolverHeight * 1,
                child: Image.asset(
                  'assets/imgs/fire.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    ),
    ); 
  }
}
