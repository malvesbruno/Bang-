import 'package:flutter/material.dart';
import '../pages/finishDuelPage.dart';
import '../pages/playingPage.dart';
import 'package:flutter/services.dart';


// Tela de treino
class TreinoDuelPage extends StatefulWidget {

  const TreinoDuelPage({super.key,});

  @override
  State<TreinoDuelPage> createState() => _TreinoDuelPageState();
}

class _TreinoDuelPageState extends State<TreinoDuelPage> {
  Duration? meuTempo; // meu tempo

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


  //define o que fazer para quando sacou
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