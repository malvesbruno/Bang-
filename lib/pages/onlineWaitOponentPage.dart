import 'package:bang/pages/onlineMenu.dart';
import 'package:bang/pages/treinoPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/enviarConvites.dart';
import '../services/enviarConvites.dart';
import '../pages/onlineVersusPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnlinewaitOponentpage extends StatefulWidget {
  const OnlinewaitOponentpage({super.key});

  @override
  State<OnlinewaitOponentpage> createState() => _OnlinewaitOponentpageState();
}

class _OnlinewaitOponentpageState extends State<OnlinewaitOponentpage> {
  final teste = true;

@override
void initState() {
  super.initState();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  esperarDueloAleatorio(userId);
}

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
                child: _AnimatedTumbleweedWithShadow(),
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

class _AnimatedTumbleweedWithShadow extends StatefulWidget {
  @override
  State<_AnimatedTumbleweedWithShadow> createState() => _AnimatedTumbleweedWithShadowState();
}

class _AnimatedTumbleweedWithShadowState extends State<_AnimatedTumbleweedWithShadow>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -35).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: Listenable.merge([_rotationController, _bounceAnimation]),
    builder: (context, child) {
      double bounceY = _bounceAnimation.value;
      
      // Escala da sombra
      double shadowScale = 1.0 - (bounceY.abs() / 15) * 0.3;

      // Deslocamento da sombra para baixo (quanto mais o tumbleweed sobe, mais a sombra desce)
      double shadowOffsetY = (bounceY.abs() / 15) * 10;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Sombra
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(0, shadowOffsetY),
              child: Transform.scale(
                scale: shadowScale,
                child: Center(
                  child: Image.asset(
                    'assets/imgs/tumbleweed_shadow.png',
                    width: 200,
                    height: 110,
                  ),
                ),
              ),
            ),
          ),

          // Tumbleweed
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(0, bounceY),
              child: Transform.rotate(
                angle: _rotationController.value * 2 * 3.1415926535,
                child: Center(
                  child: Image.asset(
                    'assets/imgs/tumbleweed.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
}