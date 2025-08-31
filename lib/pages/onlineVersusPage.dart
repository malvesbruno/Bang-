import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/playerModel.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:particles_flutter/component/particle/particle.dart';
import 'package:particles_flutter/particles_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../services/nuvem.dart';
import '../pages/onlinePage.dart';

// tela de preparação para o duelo
class DuelScreen extends StatefulWidget {
  final String player1Uid; // define o id player1
  final String player2Uid; // define o id player2

  const DuelScreen({
    super.key,
    required this.player1Uid,
    required this.player2Uid,

  });

  @override
  _DuelScreenState createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen>
    with TickerProviderStateMixin {
  late AnimationController _countdownController; //controle de animação
  final db = FirebaseDatabase.instance.ref(); // variável da database

  final AudioPlayer audioPlayer = AudioPlayer(); // define a variável que toca áudios

  bool isPlayer1 = false; //define se sou o player1
  bool isPlayer2 = false; //define se sou o player2
  Map<String, dynamic>? duelo; //informação do duelo


  String dbplayer1 = ''; 

  Player? player1; // cria a variável para pegar info do player1
  Player? player2; // cria a variável para pegar info do player2

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _iniciarSequenciaSonora(); // inicia sequência de música

    // controle da animaçãp
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

  // Chamada segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayersEIniciarDuelo();
    });

  //quando termina a contagem, vai para a pagina de duelo online
  _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
          audioPlayer.stop();
          audioPlayer.dispose();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnlineDuelPage(
            player1: isPlayer1,
            player2: isPlayer2,
            duelo: duelo!,
          ),
        ),
      );
  }});
  }

  //inicia a sequência sonora
  void _iniciarSequenciaSonora() async{
      audioPlayer.setVolume(0.7);
      await audioPlayer.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
    audioFocus: AndroidAudioFocus.gainTransientMayDuck, // Isso evita pegar foco exclusivo
        ),
      ));
      await audioPlayer.play(AssetSource("audio/bgVersusSound.mp3"));

  }

  // carrega as informações do player
  Future<void> _loadPlayers() async {
      // busca no banco de dados o player 1
      final snap1 = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.player1Uid)
          .get();
      // busca no banco de dados o player 2
      final snap2 = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.player2Uid)
          .get();

      // se os dois existem, cria um map para cada um
      if (snap1.exists && snap2.exists) {
        setState(() {
          player1 = Player.fromMap(widget.player1Uid, snap1.data()!);
          player2 = Player.fromMap(widget.player2Uid, snap2.data()!);
        });
  }
}

// carrega os players e inicia o duelo
Future<void> _loadPlayersEIniciarDuelo() async {
  await _loadPlayers(); // já carrega os jogadores

  // Esperar o duelo existir
  while (duelo == null) {
    duelo = await pegarDuelo(widget.player1Uid, widget.player2Uid); // busca o duelo
    print('Duelo' '$duelo');
      if (duelo == null) {
      await Future.delayed(const Duration(milliseconds: 500)); // espera meio segundo e tenta de novo
    }
      }

  final duelPlayer1 = duelo?['duelo']?['jogador1']?.toString().trim(); // pega o player1 do duelo
final duelPlayer2 = duelo?['duelo']?['jogador2']?.toString().trim(); // pega o player2 do duelo 
      // define se você é o player 1 ou o 2
      if (player1!.uid == duelPlayer1) {
        isPlayer1 = true;
        isPlayer2 = false;
      } else if (player1!.uid == duelPlayer2) {
        isPlayer1 = false;
        isPlayer2 = true;
      } else {
  print('⚠️ Meu UID não bate com nenhum dos jogadores do duelo!');
      }


  // Quando encontrar, inicia a contagem
  _countdownController.forward();
}


  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (player1 == null || player2 == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    //cria particulas
    List<Particle> createParticles(int count) {
      var rng = Random();
  List<Particle> particles = [];
  
  for (int i = 0; i < count; i++) {
    particles.add(Particle(
          color: const Color.fromARGB(255, 227, 205, 137).withOpacity(0.6),
      size: rng.nextDouble() * 2 + 2, // tamanho aleatório
          velocity: Offset(
        (rng.nextDouble() * 4 - 2) * 6, // x velocidade multiplicada por 3 para ficar mais rápida
        (rng.nextDouble() * 4 - 2) * 6, // y velocidade multiplicada por 3
          ),
    ));
  }
  
  return particles;
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/imgs/bg.png', fit: BoxFit.cover,)),
          Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3), // 0.0 = transparente, 1.0 = preto total
          ),
          ),
          Positioned.fill(
            child: Particles(
              awayRadius: 150,
        particles: createParticles(200), // List of particles
              height: screenHeight,
              width: screenWidth,
              onTapAnimation: true,
              awayAnimationDuration: const Duration(milliseconds: 100),
              awayAnimationCurve: Curves.linear,
              enableHover: true,
              hoverRadius: 90,
              connectDots: false,
      )
          ),
          Row(
            children: [
              Expanded(child: WantedPoster(player: player1!)),
              Expanded(child: WantedPoster(player: player2!)),
            ],
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 195, 71, 71).withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/imgs/vsLogo.png', height: 80,),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _countdownController,
              builder: (context, child) {
                final value = 5 - (_countdownController.value * 5).floor();
                return 
                Center(
                  child: Stack(
                    children: [
    // Texto com contorno (usando Paint)
                      Text(
      value > 0 ? value.toString() : "${isPlayer1}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.vt323(
                          fontSize: 100,
                          height: 0.8,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
          ..color = Color(0xFF4A251D),
                        ),
                      ),
    // Texto preenchido
                      Text(
      value > 0 ? value.toString() : "${isPlayer1}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.vt323(
                          fontSize: 100,
                          height: 0.8,
        color: Color(0xFFE33117),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WantedPoster extends StatelessWidget {
  final Player player;
  const WantedPoster({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/imgs/wantedFrame.png'),
          fit: BoxFit.contain,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(height: 65,),
          Image.asset(player.avatarPath, height: 150,),
          SizedBox(height: 
          50,),
          Text(
            player.name,
            style: GoogleFonts.vt323(
              fontSize: 30,
                    color: Color(0xFF544528),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
