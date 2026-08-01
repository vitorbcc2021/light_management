import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: LightManagementTheme.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const LightManagement());
}

class LightManagement extends StatelessWidget {
  const LightManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'LightManagement',
        debugShowCheckedModeBanner: false,
        theme: LightManagementTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}
