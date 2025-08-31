import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/nuvem.dart';
import '../pages/onlineVersusPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/tumbleWeed.dart';


// página que tenta encontrar outro jogador para duelo online
class OnlinewaitOponentpage extends StatefulWidget {
  const OnlinewaitOponentpage({super.key});

  @override
  State<OnlinewaitOponentpage> createState() => _OnlinewaitOponentpageState();
}

class _OnlinewaitOponentpageState extends State<OnlinewaitOponentpage> {
  final teste = false;

@override
void initState() {
  super.initState();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  esperarDueloAleatorio(userId);
}

  // procura um duelo aleatório 
  Future<void> esperarDueloAleatorio(String meuUid) async {
   Map<String, String?> duelo = {'dueloId': null, 'oponente': null};

  while (duelo['dueloId'] == null) {
    duelo = await tentarCombinarDuelista(meuUid);
    if (duelo['dueloId'] == null) {
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  final String uid = FirebaseAuth.instance.currentUser!.uid;
  Navigator.push(context, MaterialPageRoute(builder: (builder) => DuelScreen(player1Uid: uid, player2Uid: duelo['oponente'].toString(),)));
  // Aqui você pode chamar _loadPlayersEIniciarDuelo ou algo similar
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
              ElevatedButton(onPressed: (){}, child: Text('simular conexão'))
            ],
          ),
        ),

        // Botão no canto superior direito
         Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton(onPressed: (){
                final String uid = FirebaseAuth.instance.currentUser!.uid;
                sairDaLista(uid);
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