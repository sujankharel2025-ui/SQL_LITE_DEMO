import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/sync_service.dart';

class ConnectivityService {
  static void listen() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // go online -> sync
        SyncService.sync();
      } else {
        // offline -> do nothing; local storage will handle messages
      }
    });
  }
}
