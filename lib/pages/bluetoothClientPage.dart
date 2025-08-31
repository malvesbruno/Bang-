import 'package:bang/pages/bluetoothPreparePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/bluetoothLobbyPage.dart';
import '../widgets/tumbleWeed.dart';


/// Página que representa o cliente Bluetooth do jogo.
/// 
/// Essa tela é responsável por procurar o host, tentar se conectar e 
/// confirmar a sincronização inicial para que os jogadores possam 
/// prosseguir para a preparação da partida.
class BluetoothClientPage extends StatefulWidget {
  const BluetoothClientPage({super.key});

  @override
  State<BluetoothClientPage> createState() => _BluetoothClientPageState();
}

class _BluetoothClientPageState extends State<BluetoothClientPage> {
  final _ble = FlutterReactiveBle();
  late DiscoveredDevice _connectedDevice; // Dispositivo conectado
  late QualifiedCharacteristic _writeChar; // Característica usada para enviar/receber dados

  // UUIDs que identificam o serviço e a característica do jogo
  final Uuid serviceUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef0");
  final Uuid charUuid = Uuid.parse("abcdef01-1234-5678-1234-56789abcdef0");

  bool _isScanning = false; // Indica se o cliente está escaneando
  bool _deviceConnected = false; // Indica se já há um dispositivo conectado
  bool _modoTeste = false; // Usado para simulação em testes

  Stream<DiscoveredDevice>? _scanStream;
  bool _dialogShown = false; // Evita abrir múltiplos diálogos de Bluetooth desligado

  @override
  void initState() {
    super.initState();

    // Monitora o status do Bluetooth
    _ble.statusStream.listen((status) {
      print("Status do Bluetooth: $status");

      if (status == BleStatus.ready) {
        if (!_deviceConnected && !_isScanning) {
          startScanning();
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
        startScanning();
      }
    });
  }

  //começa a procurar pelo cliente
  void startScanning() {
    setState(() => _isScanning = true);

    _scanStream = _ble.scanForDevices(
      withServices: [serviceUuid],
      scanMode: ScanMode.lowLatency,
    );

    _scanStream!.listen((device) {
      if (_deviceConnected || device.name.isEmpty) return;

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
            // Espera mensagem "pronto" do host
            _ble.subscribeToCharacteristic(_writeChar).listen((data) async {
              if (data.isNotEmpty && data[0] == 1) {
                print("Host está pronto!");

                // Responde com "pronto"
                await _ble.writeCharacteristicWithResponse(
                  _writeChar,
                  value: [1],
                );

                _goToPreparationScreen();
              }
            });
          } catch (e) {
            print("Erro ao escutar ou responder: $e");
          }
        }
      }, onError: (error) {
        print("Erro ao conectar: $error");
      });
    }, onError: (error) {
      print("Erro no scan: $error");
    });
  }

  void simularConexao() async {
    setState(() {
      _deviceConnected = true;
    });

    await Future.delayed(Duration(seconds: 1));

    if (mounted) {
      _goToPreparationScreen();
    }
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

/// Exibe um diálogo pedindo para ativar o Bluetooth.
  void _showBluetoothEnableDialog() {
    if (_dialogShown) return;
    _dialogShown = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4A251D),
        title: Text(
          'Bluetooth está desligado',
          style: GoogleFonts.vt323(fontSize: 40, height: 0.8, color: Colors.white),
        ),
        content: Text(
          'Por favor, ative o Bluetooth para continuar.',
          style: GoogleFonts.vt323(fontSize: 20, height: 0.8, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dialogShown = false;
            },
            child: Text('Ok', style: GoogleFonts.vt323(fontSize: 20, height: 0.8, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_isScanning) {
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
            child: Image.asset('assets/imgs/bg_menu.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Text(
                      _deviceConnected
                          ? "Conectado ao host!"
                          : _isScanning
                              ? "Procurando host..."
                              : "Inicializando Bluetooth...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(
                        fontSize: 40,
                        height: 0.8,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = const Color(0xFF4A251D),
                      ),
                    ),
                    Text(
                      _deviceConnected
                          ? "Conectado ao host!"
                          : _isScanning
                              ? "Procurando host..."
                              : "Inicializando Bluetooth...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(
                        fontSize: 40,
                        height: 0.8,
                        color: const Color(0xFFE33117),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!_deviceConnected)
                  const SizedBox(
                    width: 150,
                    height: 200,
                    child: AnimatedTumbleweedWithShadow(),
                  ),
                if (_modoTeste)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: simularConexao,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                      child: const Text('Simular conexão'),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BluetoothLobbyPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF544528),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }
}
