import 'package:flutter/material.dart';
import '../pages/finishDuelPage.dart';
import '../pages/playingPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../services/enviarConvites.dart';

class OnlineDuelPage extends StatefulWidget {
  final Map duelo;
  final bool player1;
  final bool player2;
  final bool campeonato;
  final String campeonatoId;

  const OnlineDuelPage({super.key, required this.duelo, required this.player1, required this.player2, this.campeonato = false, this.campeonatoId = ""});

  @override
  State<OnlineDuelPage> createState() => _OnlineDuelPageState();
}

class _OnlineDuelPageState extends State<OnlineDuelPage> {
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
        EscutarFimDuelo(
    jogador1: widget.player1, // bool que você já deve ter
    duelId: widget.duelo['id'], // id do duelo
        );
      _escutarOutroJogador();
  }


  void _escutarOutroJogador(){
        ouvirCampoInimigo(
          campoBase: 'SacouBT',
          jogador1: widget.player1,
  duelId: widget.duelo['id'],
  onMudouStatus: (int value) {
    inimigoSacouBT(value);
  },
        );

        ouvirCampoInimigo(
          jogador1: widget.player1,
  duelId: widget.duelo['id'],
          campoBase: 'Time',
          onMudouStatus: (int value) {
            if (value > 0) {
              tempoOutroJogador = Duration(milliseconds: value);
              _tentarFinalizar();
            }
          },
        ); 
  }



  void _quandoSacou(Duration duracao) async {
      meuTempo = duracao;

    if(duracao > Duration.zero){
      adicionarMeuTempo(widget.player1, widget.duelo['id'], duracao.inMilliseconds);
    } else{
      saqueiBT(widget.player1, widget.duelo['id']);
        meuTempo = Duration.zero;
        tempoOutroJogador = Duration(milliseconds: 100);
      }


      _tentarFinalizar();
  }

  void inimigoSacouBT(int status){
    if(status == 1){
        tempoOutroJogador = Duration.zero;
        meuTempo = Duration(milliseconds: 100);
        _tentarFinalizar();
      }
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

    finalizarDuelo(widget.player1, widget.duelo['id']);
        
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