
import 'package:flutter/material.dart';
import 'pages/halaman_utama.dart';

const Color warnaUtama = Color(0xFF1769AA);
const Color warnaGelap = Color(0xFF123B5D);
const Color warnaLatar = Color(0xFFF4F7FB);
const Color warnaTeks = Color(0xFF243447);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KlinikApp());
}

class KlinikApp extends StatelessWidget {
  const KlinikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Klinik Sehat',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: warnaUtama,
          primary: warnaUtama,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: warnaLatar,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: warnaTeks,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: warnaTeks,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F9FC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE5EAF1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: warnaUtama,
              width: 1.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: warnaUtama,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: warnaUtama,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HalamanUtama(),
    );
  }
}
