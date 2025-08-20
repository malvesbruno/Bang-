import 'package:permission_handler/permission_handler.dart';

class BluetoothPermission {
  static Future<void> requestBluetoothPermissions() async {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location, // necessária em Android < 12 para escanear
    ];

    for (var permission in permissions) {
      final status = await permission.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        print('Permissão negada: $permission');
        // Você pode guiar o usuário para abrir as configurações, se quiser
      }
    }
  }
}