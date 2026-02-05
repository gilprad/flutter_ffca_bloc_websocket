import 'package:flutter/material.dart';

import 'core/di/injector.dart';
import 'core/lifecycle/app_lifecycle_handler.dart';
import 'features/market_info/presentation/pages/market_info_page.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleHandler(
      child: MaterialApp(
        title: 'Market Info',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MarketInfoPage(),
      ),
    );
  }
}
