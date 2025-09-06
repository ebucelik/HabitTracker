import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:habit_tracker/constant.dart';
import 'package:habit_tracker/cores/Database.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:habit_tracker/views/LaunchScreenWidget.dart';
import 'package:habit_tracker/views/HomeWidget.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Database.initialize();

  await initPlatformState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Database()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isLaunchedInitially = true;
  int selectedIndex = 0;

  final List<Widget> tabWidgets = [HomeWidget()];

  void onTabItemTapped(int currentIndex) {
    setState(() {
      selectedIndex = currentIndex;
    });
  }

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), handleTimeout);
  }

  void handleTimeout() {
    setState(() {
      isLaunchedInitially = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: isLaunchedInitially
          ? LaunchScreenWidget()
          : Scaffold(extendBody: true, body: HomeWidget()),
    );
  }
}

Future<void> initPlatformState() async {
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration? configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration(googleAPIKey);
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration(appleAPIKey);
  }

  if (configuration != null) {
    await Purchases.configure(configuration);
  }
}

// DefaultTabController(
//               length: 3,
//               child: Scaffold(
//                 extendBody: true,
//                 body: tabWidgets.elementAt(selectedIndex),
//                 bottomNavigationBar: BottomNavigationBar(
//                   showSelectedLabels: false,
//                   showUnselectedLabels: false,
//                   type: BottomNavigationBarType.fixed,
//                   selectedItemColor: Theme.of(context).colorScheme.primary,
//                   unselectedItemColor: AppColors.secondary.color(),
//                   items: [
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.home_filled),
//                       label: "Home",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.link_sharp),
//                       label: "Habit",
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Icon(Icons.person),
//                       label: "Account",
//                     ),
//                   ],
//                   currentIndex: selectedIndex,
//                   onTap: onTabItemTapped,
//                 ),
//               ),
//             ),
