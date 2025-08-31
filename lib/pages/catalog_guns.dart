
import 'package:bang/pages/catalog_menu.dart';
import 'package:bang/pages/comprarAvatarPage.dart';
import 'package:bang/pages/comprarRevolverPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_curl_effect/page_curl_effect.dart';
import 'package:bang/appdata.dart';
import 'package:flutter/services.dart';
import 'package:bang/services/getUserInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dadosUser.dart';


// Página de compra de revolveres
class CatalogGuns extends StatefulWidget {
  const CatalogGuns({Key? key}) : super(key: key);

  @override
  State<CatalogGuns> createState() => _CatalogGunsState();
}

class _CatalogGunsState extends State<CatalogGuns> {
  late PageCurlController _pageCurlController; // efeito de página girando
  late Size _pageSize; // tamanho da página

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();

  }


  //cria uma página para cada item da lista
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageSize = MediaQuery.of(context).size;
  _pageCurlController = PageCurlController(
    _pageSize,
    pageCurlIndex: 0,
    numberOfPage: AppData.revolveres.length,
  );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 85, 92, 57),
        foregroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (builder) => CatalogMenuPage()));
        }, icon: Icon(Icons.arrow_back)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 30, width: 60, child: Image.asset('assets/imgs/gold.png', fit: BoxFit.contain,)),
            Text(
                    AppData.qtGold.toStringAsFixed(0),
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      color: Color(0xFFFFBB01),
                    ),
                  ),
          ],
        ),
      ),
      body: SafeArea(
        child: PageCurlEffect(
          // adiciona as informações do item para cada página
          pageCurlController: _pageCurlController,
          pageBuilder: (context, index) {
            final item = AppData.revolveres[index];
            return Container(
              alignment: Alignment.center,
              color: Color(0xFFDDD7CC),
              width: _pageSize.width,
              height: _pageSize.height,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      color: Colors.brown.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 215,
                        width: 300,
                        child: Container(
                        decoration: BoxDecoration(
  gradient: item.name == 'A Vingança do Além'
      ? RadialGradient(
          colors: [
            const Color.fromARGB(255, 89, 115, 137).withOpacity(0.6),
            const Color.fromARGB(255, 7, 41, 92).withOpacity(0.8),
            Colors.black,
          ],
          stops: [0.0, 0.5, 1.0],
          center: Alignment.center,
          radius: 1.0,
        )
      : RadialGradient(
          colors: [
            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6),
            const Color.fromARGB(255, 165, 159, 147).withOpacity(0.8),
            Color.fromARGB(255, 75, 70, 59),
          ],
          stops: [0.2, 0.5, 1.0],
          center: Alignment.center,
          radius: 1.0,
        ),
  color: item.name != 'A Vingança do Além' ? Color(0xFFDDD7CC) : null,
  border: Border.all(color: Colors.brown.shade900, width: 2),
),
                        child: 
                        Column(
                          children: [
                            Image.asset(item.avatarPath, fit: BoxFit.contain,),
                          ],
                        )
                      ),
                      ),
                  ],),
                  
                  const SizedBox(height: 2),
                  !item.owned ?
                  Container(
                    decoration: BoxDecoration(color: Color.fromARGB(255, 84, 69, 40)),
                    child:  
                    SizedBox(width: 300,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40, width: 60,
                      child: Image.asset('assets/imgs/gold.png', fit: BoxFit.contain,),),
                      Text(
                    "${item.price.toStringAsFixed(0)}",
                    style: GoogleFonts.vt323(
                      fontSize: 45,
                      color: Color(0xFFFFBB01),
                    ),
                  ),
                    ],
                  ),),
                    
                    
                  ) : Container(
                    decoration: BoxDecoration(color: Color.fromARGB(255, 84, 69, 40)),
                    child:  
                    SizedBox(width: 300,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                    'Adquirido',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                    ],
                  ),),
                    
                    
                  ),
                 
                 SizedBox(height: 20,),
                SizedBox(height: 180,
                child: SingleChildScrollView(
                  child: Text(
                    item.lore,
                    style: GoogleFonts.vt323(
                      fontSize: 22,
                      height: 1.3,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),),
                SizedBox(height: 20,),

                item.avatarPath == AppData.currentRevolver ? 
                SizedBox(
                width: 400, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
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
                    'usando',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                    ]
                  ),
                  
                ),
              )
                : item.owned ? SizedBox(
                width: 400, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
    AppData.currentRevolver = item.avatarPath;
  });
  AppData.salvartudo();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
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
                    'usar',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                    ]
                  ),
                  
                ),
              ) :
                AppData.qtGold < item.price ?
                SizedBox(
                width: 400, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(180, 84, 69, 40),
                    foregroundColor: const Color.fromARGB(177, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                    'Gold insuficente',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                    ]
                  ),
                  
                ),
              ) : SizedBox(
                width: 200, // define a largura padrão dos botões
                child: ElevatedButton(
                  onPressed: () async{
                    setState(() {
                    AppData.qtGold -= item.price.toInt();
                    AppData.revolveresComprados.add(item.avatarPath);
                    item.owned = true;
                  });
                  await AppData.salvartudo();
                  try{
                    final userId = FirebaseAuth.instance.currentUser!.uid;
                    atualizarDadosJogador(userId, Dadosuser(
                      qtVitoria: AppData.qtVitoria,
                      qtDerrota: AppData.qtDerrota,
                      qtEmpate: AppData.qtEmpate,
                      qtGold: AppData.qtGold,
                      amigos: AppData.amigos,
                      avataresComprados: AppData.avataresComprados,
                      revolveresComprados: AppData.revolveresComprados,
                      gamertag: AppData.gamertag,
                      currentAvatar: AppData.currentAvatar,
                      currentRevolver: AppData.currentRevolver));
                  } catch (error) {
                    (){};
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (builder) => ComprarRevolverpage(name: item.name, avatar: item.avatarPath)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                    'Comprar',
                    style: GoogleFonts.vt323(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                    ]
                  ),
                  
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.arrow_left_rounded, size: 70, color: Color(0xFF544528),)
                ],
              )
                
                ],
              ),
            );
          },
          onForwardComplete: () {},
          onBackwardComplete: () {},
        ),
      ),
    );
  }
}
