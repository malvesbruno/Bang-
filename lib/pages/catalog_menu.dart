import 'package:bang/appdata.dart';
import 'package:bang/main.dart';
import 'package:bang/pages/catalog.dart';
import 'package:bang/pages/catalog_guns.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';



// página que dá a opção do user escolher qual loja acessar. A de revolvers ou a de avatares
class CatalogMenuPage extends StatefulWidget {
  const CatalogMenuPage({super.key});

  @override
  State<CatalogMenuPage> createState() => _CatalogMenuPageState();
}

class _CatalogMenuPageState extends State<CatalogMenuPage> {
  bool mostrar_dialog = true; // define se pode ou não mostrar o dialogo na tela
  String frase = ""; // define a frase que vai ser escolhida para o dialogo
  Timer? _timer; // timer que verifica o estado do mostrar_dialog

  void initState() {
    super.initState();
    // Força a orientação para paisagem (landscape)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    frase = getMerchantPhrase(AppData.qtVitoria, AppData.qtDerrota); // pega uma frase aleatória baseado na quantidade de derrotas e vitórias do user

    // a cada 15 segundos verifica o valor mostrar_dialog e muda ele. Além de sortear outra frase aleatória 
     _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (!mounted) return;
      if (mostrar_dialog){
        setState(() {
          mostrar_dialog = false;
        });
      }
      else{
        setState(() {
          mostrar_dialog = true;
          frase = getMerchantPhrase(AppData.qtVitoria, AppData.qtDerrota);
        });
      }

    });
  }

  @override
  void dispose() {
    // Restaura as orientações permitidas ao sair da tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.dispose();
  }

  final random = Random(); // cria um variável para que possamos usar o random.nextInt futuramente

// frases neutras
List<String> neutralPhrases = [
  "Ah, viajante, minha carroça sempre tem algo que pode mudar sua sorte.",
  "O deserto é duro, mas sempre cabe um bom negócio.",
  "Nem todo ouro brilha, mas comigo cada moeda vale.",
  "A estrada é longa… abasteça-se antes que ela lhe cobre caro.",
  "Vejo curiosidade em seus olhos. Venha, olhe de perto o que trago.",
  "Cada grão de areia guarda um segredo... e eu guardo muitos mais na minha carroça.",
  "Nem tudo no deserto é miragem… algumas riquezas são reais, e estão bem aqui.",
  "Os ventos mudam, viajante… mas sempre sopram a favor de quem sabe negociar.",
  "O destino não se escreve sozinho. Talvez algo em minha carroça lhe dê uma nova página.",
  "Os olhos veem poeira, mas o coração vê oportunidades… venha e escolha bem."
];
// frases se a quantidade de derrota for maior que a de vitórias
List<String> losingPhrases = [
  "A pólvora tem sido cruel com você, viajante… talvez eu tenha algo que alivie esse fardo.",
  "Nem sempre o destino sorri… mas uma nova arma pode fazê-lo mudar de ideia.",
  "As derrotas marcam, mas não definem. Deixe-me lhe mostrar uma chance de virar o jogo.",
  "O vento sopra contra você, mas até ele pode ser domado.",
  "Não desanime. Até os maiores pistoleiros sangraram na areia.",
  "Talvez precise mais de sorte do que de força… e sorte, eu posso vender.",
  "Até as estrelas se escondem às vezes… mas sempre retornam ao céu. Você também pode.",
  "Um revés não é o fim, é apenas o preço que o deserto cobra.",
  "Ouvi muitos lamentos nesta estrada, e quase todos mudaram de tom após me visitarem.",
  "A sorte é como um corcel selvagem… difícil de domar, mas não impossível.",
  "Se a derrota lhe pesa, talvez precise de algo mais leve… e eu sei o que pode ser."

];

// frases se a quantidade de vitórias for maior que a de derrotas
List<String> winningPhrases = [
  "Vejo a chama da vitória em seus olhos… e tenho algo digno de um vencedor.",
  "A cada duelo, sua lenda cresce. Minha carroça pode acompanhar esse brilho.",
  "Dizem que o deserto respeita apenas os fortes… você parece ser um deles.",
  "As moedas parecem leves em suas mãos, mas pesadas no meu bolso. Vamos negociar?",
  "Nem mesmo o sol ousa encarar você por muito tempo. Que tal encarar minha mercadoria?",
  "A sorte está do seu lado… e eu sei como mantê-la acesa.",
  "O brilho da sua vitória atrai até as cobras do deserto… mas comigo só atrai boas ofertas.",
  "Quando o sangue quente se mistura à areia, apenas os fortes permanecem de pé. Você está entre eles.",
  "Cada vitória sua soa como ouro tilintando… e eu sempre reconheço esse som.",
  "Não é todo dia que a morte recua… talvez queira algo para garantir que continue assim.",
  "Os ventos sussurram seu nome, viajante. Que tal gravá-lo também em uma boa peça da minha coleção?"

];

// função que pega a frase aleatória baseada na quantidade de vitórias e derrotas
String getMerchantPhrase(int wins, int losses) {
  if (wins > 5 && wins > losses) {
    // se vitória maior que 5 e maior que derrotas: frase de vitória
    return winningPhrases[random.nextInt(winningPhrases.length)];
  } else if (losses > 5 && losses > wins) {
    // se derrota maior que 5 e maior que vitórias: frase de derrota
    return losingPhrases[random.nextInt(losingPhrases.length)];
  } else {
    // caso nenhum dos dois: frase neutra  
    return neutralPhrases[random.nextInt(neutralPhrases.length)];
  }
}

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
        return Scaffold(
      backgroundColor: Colors.black,
      body:  Stack(
            children: [
              // Fundo
              Positioned.fill(
                child: Image.asset(
                  'assets/imgs/catalogMenu.png', // imagem do deserto
                  fit: BoxFit.cover,
                )
              ),
              Positioned(
                top: screenHeight / 2 - 50,
                left: screenWidth / 2 - 160,
                child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                width: 230, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (builder) => Catalog()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A2B0F),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                    'Avatares',
                    style: GoogleFonts.vt323(
                      fontSize: 35,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                    ]
                  ),
                  
                ),
              ),
              SizedBox(height: 20,),
                  SizedBox(
                width: 230, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (builder) => CatalogGuns()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A2B0F),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                    'Revolveres',
                    style: GoogleFonts.vt323(
                      fontSize: 35,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                    ]
                  ),
                  
                ),
              ),
                ],
              )),
              

              mostrar_dialog ?
              Positioned(
                bottom: 5,
                left: (screenWidth / 2) - ((screenWidth / 1.2) / 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(200, 0, 0, 0),
                  ),
                  child: SizedBox(
                    width: screenWidth / 1.2,
                    height: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 50,),
                            Text('Selene', style: TextStyle(fontSize: 25, color: Colors.white),),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 50,),
                            Expanded(child: Text(frase, style: TextStyle(fontSize: 15, color: Colors.white)))
                          ],
                        )
                        
                        
                      ],
                    ),
                  ),
                )) : Container(),
                Positioned(
                  left: 20,
                  top: 20,
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (builder) => MyHomePage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A2B0F),
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white,)))
              ])); 
        });
  }
}
