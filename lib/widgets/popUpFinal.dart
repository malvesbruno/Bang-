import 'package:bang/services/getUserInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../appdata.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinalPopup extends StatefulWidget {
  final Duration duracao;
  final bool venceu;
  final bool empate;
  final bool sacouBT;
  final bool sacaramBT;
  final bool treino;
  final VoidCallback onReturn;
  final bool campeonato;
  final String campeonatoId;

  const FinalPopup({super.key, required this.duracao, required this.venceu, required this.empate, required this.sacouBT, required this.sacaramBT, required this.onReturn, this.treino = false,
  this.campeonato = false, this.campeonatoId = ''});

  @override
  State<FinalPopup> createState() => _FinalPopupState();
}

class _FinalPopupState extends State<FinalPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late String frase;
  

  final List<String> venceuFrases = [
    "Essa cidade é pequena demais pra nós dois...",
    "Eu não sou besta pra tirar onda de herói...",
    "O homem de preto...",
    "O deserto lembra... mas não perdoa.",
    "Pelos seus reflexos, você já era um condenado à morte.",
    "Essa é a última canção de cowboys.",
    "Era uma vez no oeste... você.",
    "Na dúvida, atire primeiro.",
    "Ele veio do nada... e voltou pra lá.",
    "Te vejo no inferno, parceiro.",
    "O sol nasceu, mas não pra todo mundo.",
    "Sangue seco no deserto não deixa vestígio.",
    "O gatilho mais rápido do oeste.",
    "Vingança é um jogo de tolos",
    "Eu sou o melhor que há, e é só o que precisa saber",
    "O velho oeste nunca esquece um nome... ou um revólver.",
    "Tem gente que atira. Tem gente que cai. E tem você.",
    "A espera dos cavaleiros fantasmas",
    "Cowboys morrem, lendas vivem.",
    "No jogo do gatilho, pensar já é perder."
  ];
  final List<String> perdeufrases = [
    "Não era meu duelo... era meu destino.",
  "A mira dele era boa. Ou eu que tava cansado.",
  "Fui mais rápido que todos... menos ele.",
  "Agora entendo por que chamam isso de 'fim da linha'.",
  "Diz pra minha mãe que eu tentei.",
  "Eu devia ter escolhido a espingarda.",
  "Morri como vivi: teimoso.",
  "Isso tudo por um punhado de munição...",
  "Me enterra de chapéu, tá?",
  "Você é bom... mas ainda vai sangrar como eu.",
  "Esse sol nunca brilhou pra mim mesmo.",
  "Me pegou no reload... maldito.",
  "Cowboys também choram.",
  "Você ganhou dessa vez... só dessa.",
  "Se o inferno tiver bangue-bangue, me espera lá.",
  "Diz pra eles que eu lutei. Mesmo perdendo.",
  "Não era meu dia. Nem meu oeste.",
  "Ainda ouvi o tiro. Só não consegui desviar.",
  "Queria mais um último gole de uísque...",
  "Pior que morrer... é saber que ele sorriu."
  ];
   final List<String> sacouFrases = [
  "A pressa é inimiga do gatilho.",
  "Sacou antes… mas não viveu pra contar.",
  "No velho oeste, a ansiedade mata.",
  "O desespero tem cheiro de pólvora fria.",
  "Coragem sem controle é só burrice.",
  "Mais rápido que a sombra… e tão frágil quanto ela.",
  "Achou que era um filme. Descobriu que era um funeral.",
  "O oeste não perdoa dedos nervosos.",
  "Quis ser lenda. Virou estatística.",
  "Só teve tempo pra um suspiro… e um erro.",
  "Era cedo demais, parceiro.",
  "Sacou sem mirar. E mirou no fim.",
  "Teu próprio gatilho foi tua sentença.",
  "A vida piscou antes do revólver.",
  "Tem duelo que é ganho no silêncio.",
  "Pulou a música do destino... e deu azar.",
  "Se precipitou. O chão agradeceu.",
  "Faltou esperar o sino tocar.",
  "O oeste não gosta de apressados.",
  "Mais um que confundiu sede com sede de vingança."
];
final List<String> empateFrases = [
  "Dois tiros. Um silêncio eterno.",
  "O oeste não escolheu um vencedor hoje.",
  "Duas balas, dois destinos... nenhum sobreviveu.",
  "Você era bom. Pena que eu também era.",
  "No fim, só o pó do deserto venceu.",
  "Nossos nomes, gravados na mesma lápide.",
  "Tão rápido quanto eu... maldita coincidência.",
  "Dizem que no empate, o tempo para.",
  "O deserto engoliu dois heróis hoje.",
  "Foi justo. Foi fatal.",
  "Dois trovões no mesmo segundo.",
  "O duelo perfeito. O fim inevitável.",
  "Se fosse um filme, a câmera congelava aqui.",
  "Empate... ou pacto de sangue?",
  "O velho oeste ama finais trágicos.",
  "Caímos juntos. Morreria de novo assim.",
  "A lenda começa quando ninguém vence.",
  "Hoje, o respeito falou mais alto que a pólvora.",
  "Nem vivo, nem morto. Só igual.",
  "Dois cowboys. Uma história. Nenhum epílogo."
];
final List<String> treinoSucesso = [
  "O gatilho tá pegando fogo!",
  "Cada treino te deixa mais rápido.",
  "Tá quase lá, cowboy!",
  "A prática faz o mestre do revólver.",
  "Hoje o deserto é teu aliado.",
  "Reflexos de um verdadeiro pistoleiro.",
  "Não é sorte, é treino!",
  "Esse tiro foi no coração da precisão.",
  "Só falta um passo pra lenda.",
  "A mira afiada é fruto da dedicação.",
  "O oeste observa os perseverantes.",
  "Quem treina assim não perde tempo.",
  "Tá na linha de fogo do sucesso.",
  "Mais rápido que o vento e o relógio.",
  "Treinar é o segredo dos campeões.",
  "Não existe atalho no deserto.",
  "O sol nasce pra quem não desiste.",
  "Gatilho quente, mente fria.",
  "O duelo começa antes do tiro.",
  "Treino forte, vitória certa.",
];
final List<String> treinoErro = [
  "Calma, o velho oeste não perdoa pressa.",
  "Errou o tempo, mas ainda tem bala no tambor.",
  "Não atire no escuro, mire no alvo.",
  "O duelo é na calma, não na afobação.",
  "Gatilho nervoso nunca fez história.",
  "Hoje foi só treino, amanhã é batalha.",
  "O deserto é severo, mas você pode aprender.",
  "Não desanime, até o melhor começou assim.",
  "Tire um gole de calma antes do próximo tiro.",
  "Recarregue a calma, não só a arma.",
  "Errou o passo, mas dança quem sabe.",
  "Paciência é a arma dos campeões.",
  "A sorte favorece os que treinam.",
  "Cada erro é um passo pro sucesso.",
  "Não deixe o nervosismo roubar seu tiro.",
  "Volte mais forte, cowboy.",
  "O fogo da derrota alimenta a vitória.",
  "Aprenda a esperar o sinal do destino.",
  "Mais treino, menos tropeço.",
  "No deserto, até o vento aprende devagar.",
];



  @override
  void initState() {
    super.initState();
    if (!widget.treino){
    if (widget.venceu || widget.sacaramBT){
      frase = (venceuFrases..shuffle()).first;
    } else if(!widget.venceu && !widget.sacouBT && !widget.empate){
      frase = (perdeufrases..shuffle()).first;
    } else if(!widget.venceu && widget.sacouBT && !widget.empate){
      frase = (sacouFrases..shuffle()).first;
    } else{
      frase = (empateFrases..shuffle()).first;
    }} else{
      if (widget.sacouBT){
         frase = (treinoErro..shuffle()).first;
      } else{
        frase = (treinoSucesso..shuffle()).first;
      }
    }

    if(!widget.treino){
    if (widget.venceu || widget.sacaramBT) {
      if (widget.campeonato){
        AppData.qtVitoria += 2;
      }
      else{
      AppData.qtVitoria++;
      AppData.qtGold += 100;
      }
  } else if (widget.empate) {
    AppData.qtEmpate++;
    AppData.qtGold += 50;
  } else if (widget.sacouBT || (!widget.venceu && !widget.empate)) {
    AppData.qtDerrota++;
  }
  // Salva no banco
  AppData.salvarEstatisticas();
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    Future.delayed(const Duration(seconds: 1), () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getResult(){
    if(!widget.treino){
    if (widget.venceu || widget.sacaramBT){
      return "YOU WIN";
    } else if(widget.sacouBT || !widget.venceu && !widget.empate){
      return "YOU LOOSE";
    } else{
      return "DRAW";
    }} else{
      return "TRAINING";
    }
  }

  String _getTime(){
    if (!widget.sacouBT && !widget.sacaramBT){
      return "Tempo de reação: ${widget.duracao.inMilliseconds} ms";
    } else if(widget.sacouBT && !widget.sacaramBT){
      return "Você sacou antes da hora";
    } else{
      return "Seu oponente sacou antes da hora";
    }
  }

  String _getBounty(){
    final base = 20;
    final v = AppData.qtVitoria;
  final d = AppData.qtDerrota;
  final e = AppData.qtEmpate;

  double bounty = base + (v * 250) - (d * 100) - (e * 50);
  bounty = bounty.clamp(0, 10000000); // mínimo 0, máximo 10 mil
  final userId = FirebaseAuth.instance.currentUser!.uid;
  atualizarDadosJogador(userId, {
    'qtVitoria': AppData.qtVitoria,
    'qtDerrota': AppData.qtDerrota,
    'qtEmpate': AppData.qtEmpate,
    'qtGold': AppData.qtGold,

  });

  return "${bounty.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
  width: 450,
  height: 800,
  child: SingleChildScrollView(
  child: Container(
    width: 400,
    height: 850, // Altura base do cartaz
    decoration: BoxDecoration(
      image: DecorationImage(
        image: widget.venceu || widget.sacaramBT || widget.empate || widget.treino ? AssetImage('assets/imgs/wantedFrame.png') : AssetImage('assets/imgs/wantedFrameLost.png'),
        fit: BoxFit.fill,
      ),
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 175),
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Text(
          _getResult(),
          style: GoogleFonts.vt323(
            fontSize: 50,
            color: Color(0xFF544528),
            fontWeight: FontWeight.bold,
          ),
        ),
        
        Image.asset(
          'assets/imgs/avatares/avatar1_pose2.png',
          height: 340,
          fit: BoxFit.contain,
        ),
          ],
        ),
        const SizedBox(height: 75),
        Text(
          'R\$' "${_getBounty()}",
          style: GoogleFonts.vt323(fontSize: 40,
          color: Color(0xFF544528),),
        ),
        Text(
          '"$frase"',
          style: GoogleFonts.vt323(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: Color(0xFF544528),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          _getTime(),
          style: GoogleFonts.vt323(fontSize: 23,
          color: Color(0xFF544528),),
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            ElevatedButton(
          onPressed: widget.onReturn,
          style: ElevatedButton.styleFrom(
            backgroundColor:Color(0xFF544528),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:  Text(
          widget.campeonato ? 'continuar' :'Voltar',
          style: GoogleFonts.vt323(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          textAlign: TextAlign.center,
        ),
        ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    ),
  ),
),
),

      ),
    );
  }
}
