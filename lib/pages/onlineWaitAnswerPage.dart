import 'package:bang/pages/onlineMenu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/nuvem.dart';
import '../pages/onlineVersusPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/tumbleWeed.dart';

// página para aguardar outro jogador aceitar o convite
class Onlinewaitanswerpage extends StatefulWidget {
  final String conviteId;
  final String amigoId;
  const Onlinewaitanswerpage({super.key, required this.conviteId, required this.amigoId});

  @override
  State<Onlinewaitanswerpage> createState() => _OnlinepreparepageState();
}

class _OnlinepreparepageState extends State<Onlinewaitanswerpage> {
  final teste = false;

@override
void initState() {
  super.initState();
  aguardarResposta(widget.amigoId, widget.conviteId, onMudouStatus);
}
  
  // verifica se o status do duelo mudou
  void onMudouStatus(String status, String uid, String conviteId) {
    dynamic conviteRef = db.child('convites').child(uid).child(conviteId);
    if (status == 'aceito') {
      conviteRef.remove();
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      Navigator.push(context, MaterialPageRoute(builder: (builder) => DuelScreen(player1Uid: uid, player2Uid: widget.amigoId,)));
    } else if(status == 'recusado'){
      conviteRef.remove();
       Navigator.push(context, MaterialPageRoute(builder: (builder) => onlineMenuPage()));
    }
  }

  void simularAceito(String Amigouid, String conviteUid) async{
    final convitesRef = db.child('convites').child(Amigouid);
    final snapshot = await convitesRef.get();

if (snapshot.exists) {
  final convite = Map<String, dynamic>.from(snapshot.value as Map);
  final String uid = FirebaseAuth.instance.currentUser!.uid;
   await aceitarConvite(Amigouid, conviteUid, convite, uid);
} 
  }


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 243, 165, 152),
    body: Stack(
      children: [
        Positioned.fill(
  child: Image.asset(
    'assets/imgs/bg_menu.png', // ou o caminho da sua imagem
    fit: BoxFit.cover,
  ),
),
Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3), // 0.0 = transparente, 1.0 = preto total
      ),
    ),
        // Conteúdo centralizado
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
              Text(
                "Aguardando jogador...",
                 textAlign: TextAlign.center,
      style: GoogleFonts.vt323(
        fontSize: 40,
        height: 0.8,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = Color(0xFF4A251D),
      ),
              ),

              Text(
                "Aguardando jogador...",

                 textAlign: TextAlign.center,
      style: GoogleFonts.vt323(
        fontSize: 40,
         height: 0.8,
        color: Color(0xFFE33117),
  ),
              ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 150,
                height: 200,
                child: AnimatedTumbleweedWithShadow(),
              ),
              if(teste)
              ElevatedButton(onPressed: (){simularAceito(widget.amigoId, widget.conviteId);}, child: Text('simular conexão'))
            ],
          ),
        ),

        // Botão no canto superior direito
         Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton(onPressed: (){
                deletarConvite(widget.amigoId, widget.conviteId);
                Navigator.pop(context);
                }, 
            style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
            child: Icon(Icons.arrow_back))),
      ],
    ),
  );
}
}
