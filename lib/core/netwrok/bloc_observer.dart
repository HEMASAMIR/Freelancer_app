import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('🟢 onCreate — ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('⚡ onEvent — ${bloc.runtimeType} | $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('🔄 onChange — ${bloc.runtimeType}');
    print('   current: ${change.currentState.runtimeType}');
    print('   next:    ${change.nextState.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(
      '➡️  onTransition — ${bloc.runtimeType} | ${transition.event.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('🔴 onError — ${bloc.runtimeType} | $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('🔴 onClose — ${bloc.runtimeType}');
  }
}
