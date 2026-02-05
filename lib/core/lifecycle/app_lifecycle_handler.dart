import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../ws/ws_manager.dart';

class AppLifecycleHandler extends StatefulWidget {
  const AppLifecycleHandler({super.key, required this.child});

  final Widget child;

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[APP] lifecycle=${state.name}');
    final manager = GetIt.instance<WsManager>();
    Future<void> run(Future<void> Function() fn) async {
      try {
        await fn();
      } catch (e) {
        debugPrint('[APP] lifecycle handler error: $e');
      }
    }

    switch (state) {
      case AppLifecycleState.resumed:
        Future.microtask(() => run(manager.resume));
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        Future.microtask(() => run(manager.pause));
        break;
      case AppLifecycleState.detached:
        Future.microtask(() => run(manager.closeAll));
        break;
      case AppLifecycleState.hidden:
        Future.microtask(() => run(manager.pause));
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
