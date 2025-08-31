import 'package:flutter/material.dart';
import '../pages/finishDuelPage.dart';
import '../pages/playingPage.dart';
import 'package:flutter/services.dart';
import '../services/nuvem.dart';

//página que controla a página do duelo online
class OnlineDuelPage extends StatefulWidget {
  final Map duelo; // map de informações do duelo
  final bool player1; // define se é o player 1
  final bool player2; // define se é o player 2
  final bool campeonato; // define se é campeonato
  final String campeonatoId; // campeonato ID


  const OnlineDuelPage({super.key, required this.duelo, required this.player1, required this.player2, this.campeonato = false, this.campeonatoId = ""});

  @override
  State<OnlineDuelPage> createState() => _OnlineDuelPageState();
}

class _OnlineDuelPageState extends State<OnlineDuelPage> {
  Duration? meuTempo; // meu tempo
  Duration? tempoOutroJogador; // tempo de outro jogador
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
    // escutar o fim do duelo
        EscutarFimDuelo(
    jogador1: widget.player1, // bool que você já deve ter
    duelId: widget.duelo['id'], // id do duelo
        );
        // escutar mensagem de outro jogador
      _escutarOutroJogador();
  }


  // escuta o outro jogador
  void _escutarOutroJogador(){
    // verifica se o inimigo sacou antes da hora
        ouvirCampoInimigo(
          campoBase: 'SacouBT',
          jogador1: widget.player1,
  duelId: widget.duelo['id'],
  onMudouStatus: (int value) {
    inimigoSacouBT(value);
  },
        );
      // verifica o tempo do inimigo
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


  // define o que fazer quando você saca
  void _quandoSacou(Duration duracao) async {
      meuTempo = duracao; //meu tempo

    if(duracao > Duration.zero){
      // adiciona meu tempo
      adicionarMeuTempo(widget.player1, widget.duelo['id'], duracao.inMilliseconds);
    } else{
      // saquei antes da hora
      saqueiBT(widget.player1, widget.duelo['id']);
        meuTempo = Duration.zero;
        tempoOutroJogador = Duration(milliseconds: 100);
      }

      // tenta finalizar
      _tentarFinalizar();
  }
 
  // o que fazer se o inimigo sacou antes da hora
  void inimigoSacouBT(int status){
    if(status == 1){
        tempoOutroJogador = Duration.zero;
        meuTempo = Duration(milliseconds: 100);
        _tentarFinalizar();
      }
  }

  // tenta finalizar o duelo
  void _tentarFinalizar() {
    if(_finalizado) return;
      if (meuTempo != null && tempoOutroJogador != null) {
        _finalizado = true;
        final saqueiAntes = meuTempo == Duration.zero; // se o meu tempo for igual à zero, eu saquei antes do tempo
        final outroSacouAntes = tempoOutroJogador == Duration.zero; // se o tempo do inimigo é igual à zero, o inimigo sacou antes do tempo

        bool venceu;
        bool empate = false;

        // se os dois sacaram antes da hora, deu empate
        if (saqueiAntes && outroSacouAntes) {
          empate = true;
          venceu = false;
           // se eu saquei antes da hora, eu perdi
        } else if (saqueiAntes) {
          venceu = false;
           // se o outro jogador jogou antes da hora, eu ganhei
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