// import 'dart:async';
//
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// class ConnectivityService {
//   late StreamSubscription _subscription;
//
//   static bool hasConnection = true;
//
//   ConnectivityService() {
//     checkInternetConnection();
//   }
//
//   Future<void> checkInternetConnection() async {
//     try {
//       _subscription = Connectivity().onConnectivityChanged.listen((status) async {
//         if (status.contains(ConnectivityResult.mobile)  ||
//             status.contains(ConnectivityResult.wifi) ||
//             status.contains(ConnectivityResult.vpn)) {
//           hasConnection = true;
//         } else {
//           hasConnection = false;
//         }
//       });
//     } catch (_) {}
//   }
//
//   void cancel() => _subscription.cancel();
// }
