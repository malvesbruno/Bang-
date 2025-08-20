import 'package:flutter/material.dart';
import '../pages/finishDuelPage.dart';
import '../pages/playingPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class TreinoDuelPage extends StatefulWidget {

  const TreinoDuelPage({super.key,});

  @override
  State<TreinoDuelPage> createState() => _TreinoDuelPageState();
}

class _TreinoDuelPageState extends State<TreinoDuelPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  Duration? meuTempo;
  Duration? tempoOutroJogador;
  bool _finalizado = false;

  @override
  void initState() {
    super.initState();
    // Força a orientação para paisagem (landscape)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

   void _quandoSacou(Duration duracao) async {
    meuTempo = duracao;

    Navigator.pop(context);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FinalDuelpage(
            duracao: meuTempo!,
            empate: false,
            venceu: false,
            sacaramBT: false,
            sacouBT: duracao == Duration(milliseconds: 0),
            treino: true,
          ),
        ),
      );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayingPage(
        onReacaoFinalizada: _quandoSacou,
        treino: true,
      ),
    );
  }
}