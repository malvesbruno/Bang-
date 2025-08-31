import 'package:flutter/material.dart';
import '../pages/finishDuelPage.dart';
import '../pages/playingPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

//página que controla a página do duelo offline
class OfflineDuelPage extends StatefulWidget {
  final QualifiedCharacteristic writeChar; // recebe o código para enviar info por bluetooth

  const OfflineDuelPage({super.key, required this.writeChar});

  @override
  State<OfflineDuelPage> createState() => _OfflineDuelPageState();
}

class _OfflineDuelPageState extends State<OfflineDuelPage> {
  final flutterReactiveBle = FlutterReactiveBle(); // variável que controla o bluetooth
  Duration? meuTempo; // meu tempo
  Duration? tempoOutroJogador; // tempo do outro jogado
  bool _finalizado = false; // se o duelo já foi finalizado 

  @override
  void initState() {
    super.initState();
    // Força a orientação para paisagem (landscape)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // escuta a mensagem do outro jogador
    _escutarOutroJogador();
  }


  // escuta a mensagem de outro jogador
  void _escutarOutroJogador() {
  flutterReactiveBle.subscribeToCharacteristic(widget.writeChar).listen((data) {
      final recebido = String.fromCharCodes(data); // info recebidos pelo o outro jogador
      final outroTempo = Duration(milliseconds: int.parse(recebido)); // transforma a info em duração
      // define o tempo do outro jogador como igual ao tempo
      setState(() {
        tempoOutroJogador = outroTempo;
      });
      // tenta finalizar o duelo
      _tentarFinalizar();
    });
  }

    // define o que vai ser feito quando o user saca
   void _quandoSacou(Duration duracao) async {
    meuTempo = duracao; // meu tempo

    await flutterReactiveBle.writeCharacteristicWithResponse(
      widget.writeChar,
      value: duracao.inMilliseconds.toString().codeUnits,
    ); // manda a mensagem para o outro jogador
    // tenta finalizar o duelo
    _tentarFinalizar();
  }

 
  // tenta finalizar o duelo
  void _tentarFinalizar() {
    if(_finalizado) return; // se o duelo já finalizou, volta
    if (meuTempo != null && tempoOutroJogador != null) {
      _finalizado = true; // seta finalizado como true
      final saqueiAntes = meuTempo == Duration.zero; // se meu tempo for igual à zero, eu saquei antes do tempo
      final outroSacouAntes = tempoOutroJogador == Duration.zero; // se o tempo do inimigo for igual à zero, ele sacou antes do tempo

      bool venceu;
      bool empate = false;

    // se os dois sacaram antes, dá empate
    if (saqueiAntes && outroSacouAntes) {
      empate = true;
      venceu = false;
    // se eu sanquei antes, eu perdi
    } else if (saqueiAntes) {
      venceu = false;
      // se o inimigo sacou antes, eu venci
    } else if (outroSacouAntes) {
      venceu = true;
    } else {
      // Ninguém sacou antes: quem for mais rápido vence
      empate = meuTempo == tempoOutroJogador;
      venceu = !empate && meuTempo! < tempoOutroJogador!;
    }

      //leva para a FinishDuel
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FinalDuelpage(
            duracao: meuTempo!,
            empate: empate,
            venceu: venceu,
            sacaramBT: outroSacouAntes,
            sacouBT: saqueiAntes,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayingPage(
        onReacaoFinalizada: _quandoSacou,
      ),
    );
  }
}