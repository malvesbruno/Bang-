import 'package:flutter/material.dart';
import '../pages/finishDuelPage.dart';
import '../pages/playingPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class OfflineDuelPage extends StatefulWidget {
  final QualifiedCharacteristic writeChar;

  const OfflineDuelPage({super.key, required this.writeChar});

  @override
  State<OfflineDuelPage> createState() => _OfflineDuelPageState();
}

class _OfflineDuelPageState extends State<OfflineDuelPage> {
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
    _escutarOutroJogador();
  }


  void _escutarOutroJogador() {
  flutterReactiveBle.subscribeToCharacteristic(widget.writeChar).listen((data) {
      final recebido = String.fromCharCodes(data);
      final outroTempo = Duration(milliseconds: int.parse(recebido));
      print("Outro jogador sacou em $outroTempo");

      tempoOutroJogador = outroTempo;
      _tentarFinalizar();
    });
  }

   void _quandoSacou(Duration duracao) async {
    meuTempo = duracao;

    await flutterReactiveBle.writeCharacteristicWithResponse(
      widget.writeChar,
      value: duracao.inMilliseconds.toString().codeUnits,
    );

    print("Enviei meu tempo: ${duracao.inMilliseconds} ms");

    _tentarFinalizar();
  }

  void _tentarFinalizar() {
    if(_finalizado) return;
    if (meuTempo != null && tempoOutroJogador != null) {
      _finalizado = true;
      final saqueiAntes = meuTempo == Duration.zero;
      final outroSacouAntes = tempoOutroJogador == Duration.zero;

      bool venceu;
      bool empate = false;

    if (saqueiAntes && outroSacouAntes) {
      empate = true;
      venceu = false;
    } else if (saqueiAntes) {
      venceu = false;
    } else if (outroSacouAntes) {
      venceu = true;
    } else {
      // Ninguém sacou antes: quem for mais rápido vence
      empate = meuTempo == tempoOutroJogador;
      venceu = !empate && meuTempo! < tempoOutroJogador!;
    }


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