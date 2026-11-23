import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/providers/favorite_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/services/recipe_service.dart';
import 'package:flutter_application_1/widgets/identity_footer.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Latihan 1 Modul 6
        // Provider biasa: RecipeService tidak berubah, jadi tidak perlu notifyListeners
        Provider(
          create: (context) => RecipeService(),
          dispose: (context, service) => service.close(),
        ),
      ],
      child: const ResepKuApp(),
    ),
  );
}

class ResepKuApp extends StatelessWidget {
  const ResepKuApp({super.key});
  @override
  Widget build(BuildContext context) {
    // watch: MaterialApp harus rebuild setiap kali tema berubah
    final themeMode = context.watch<ThemeProvider>().themeMode;
    return MaterialApp(
      title: 'ResepKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      builder: (context, child) =>
          IdentityFooter(child: child!), // tetap dipertahankan
      home: const HomePage(),
    );
  }
}
