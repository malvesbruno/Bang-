import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../pages/bluetoothLobbyPage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/bluetoothPreparePage.dart';
import '../widgets/tumbleWeed.dart';


/// Página que representa o host Bluetooth do jogo.
/// 
/// Essa tela é responsável por procurar o cliente, tentar se conectar e 
/// confirmar a sincronização inicial para que os jogadores possam 
/// prosseguir para a preparação da partida.
class BluetoothHostPage extends StatefulWidget {
  const BluetoothHostPage({super.key});

  @override
  State<BluetoothHostPage> createState() => _BluetoothHostPageState();
}

class _BluetoothHostPageState extends State<BluetoothHostPage> {
  final _ble = FlutterReactiveBle();
  late DiscoveredDevice _connectedDevice; // Dispositivo conectado
  late QualifiedCharacteristic _writeChar;  // Característica usada para enviar/receber dados

  // UUIDs que identificam o serviço e a característica do jogo
  final Uuid serviceUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef0");
  final Uuid charUuid = Uuid.parse("abcdef01-1234-5678-1234-56789abcdef0");

  bool _isAdvertising = false; // Indica se o host está escaneando
  bool _deviceConnected = false; // Indica se já há um dispositivo conectado
  bool _modoTeste = false; // Usado para simulação em testes

  Stream<DiscoveredDevice>? _advertisingStream;

  bool _dialogShown = false;  // Evita abrir múltiplos diálogos de Bluetooth desligado


@override
void initState() {
  super.initState();

  // Monitora o status do Bluetooth
  _ble.statusStream.listen((status) {
    print("Status do Bluetooth: $status");

    if (status == BleStatus.ready) {
      if (!_deviceConnected && !_isAdvertising) {
        startAdvertising();
      }
    } else if (status == BleStatus.poweredOff) {
      _showBluetoothEnableDialog();
    }
  });

  // Checa o status inicial após a renderização da tela
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final initialStatus = await _ble.statusStream.first;
    if (initialStatus == BleStatus.poweredOff) {
      _showBluetoothEnableDialog();
    } else if (initialStatus == BleStatus.ready) {
      startAdvertising();
    }
  });
}

/// Simula uma conexão bem-sucedida (modo de teste).
void simularConexao() async {
  setState(() {
    _deviceConnected = true;
  });

  await Future.delayed(Duration(seconds: 1));

  if (mounted) {
    _goToPreparationScreen();
  }
}

/// Exibe um diálogo pedindo para ativar o Bluetooth.
void _showBluetoothEnableDialog() {
  if (_dialogShown) return;
  _dialogShown = true;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Color(0xFF4A251D),
      title: Text('Bluetooth está desligado',
      style: GoogleFonts.vt323(
        fontSize: 40,
         height: 0.8,
        color: Colors.white,
  ),),
      content: Text('Por favor, ative o Bluetooth para continuar.',
      style: GoogleFonts.vt323(
        fontSize: 20,
         height: 0.8,
        color: Colors.white,
  )
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _dialogShown = false;
          },
          child: Text('Ok', style: GoogleFonts.vt323(
        fontSize: 20,
         height: 0.8,
        color: Colors.white,
  )),
        ),
      ],
    ),
  );
}

  /// Inicia a varredura para encontrar o host via Bluetooth.
  void startAdvertising() {
  setState(() => _isAdvertising = true);

  _advertisingStream = _ble.scanForDevices(
    withServices: [serviceUuid],
    scanMode: ScanMode.lowLatency,
  );

  _advertisingStream!.listen((device) {
    if (_deviceConnected) return;

    if (device.name.isNotEmpty) {
      // Pare o scan assim que encontrar um dispositivo válido
      _advertisingStream = null;

      // Conecta ao dispositivo e escuta o estado da conexão
      _ble.connectToDevice(id: device.id).listen((connectionState) async {
        if (connectionState.connectionState == DeviceConnectionState.connected) {
          setState(() {
            _deviceConnected = true;
            _connectedDevice = device;
          });

          _writeChar = QualifiedCharacteristic(
            serviceId: serviceUuid,
            characteristicId: charUuid,
            deviceId: device.id,
          );

          try {
          // Envia "pronto" para o outro jogador
          await _ble.writeCharacteristicWithResponse(
            _writeChar,
            value: [1],
          );

          // Escuta a resposta do outro jogador (também [1] = pronto)
          final responseChar = QualifiedCharacteristic(
            serviceId: serviceUuid,
            characteristicId: charUuid,
            deviceId: device.id,
          );

          _ble.subscribeToCharacteristic(responseChar).listen((data) {
            if (data.isNotEmpty && data[0] == 1) {
              print("Jogador remoto confirmou que está pronto!");
              _goToPreparationScreen(); // Vamos criar isso
            }
          });

        } catch (e) {
          print("Erro ao enviar ou escutar característica: $e");
        }
        }
      }, onError: (error) {
        print("Erro na conexão: $error");
      });
    }
  }, onError: (error) {
    print("Erro no scan: $error");
  });
}

   /// Vai para a tela de preparação do jogo após conexão bem-sucedida.
  void _goToPreparationScreen() {
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BluetoothPreparePage(writeChar: _writeChar,)),
    );
  }
}

  @override
  void dispose() {
    if (_isAdvertising) {
      _ble.deinitialize();
    }
    super.dispose();
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
                _deviceConnected
                    ? "Jogador conectado!"
                    : _isAdvertising
                        ? "Aguardando jogador..."
                        : "Inicializando Bluetooth...",
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
                _deviceConnected
                    ? "Jogador conectado!"
                    : _isAdvertising
                        ? "Aguardando jogador..."
                        : "Inicializando Bluetooth...",
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
              if (!_deviceConnected)
              SizedBox(
                width: 150,
                height: 200,
                child: AnimatedTumbleweedWithShadow(),
              ),
             
              if (_modoTeste)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: simularConexao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: Text('Simular conexão'),
                ),
              ),
            ],
          ),
        ),

        // Botão no canto superior direito
         Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothLobbyPage()));}, 
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

