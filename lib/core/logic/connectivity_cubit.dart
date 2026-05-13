import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  ConnectivityCubit() : super(ConnectivityStatus.connected) {
    _checkInitialStatus();
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // connectivity_plus 6.0.0+ returns a list
      if (results.contains(ConnectivityResult.none)) {
        emit(ConnectivityStatus.disconnected);
      } else {
        emit(ConnectivityStatus.connected);
      }
    });
  }

  Future<void> _checkInitialStatus() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      emit(ConnectivityStatus.disconnected);
    } else {
      emit(ConnectivityStatus.connected);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
