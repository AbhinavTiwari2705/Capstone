import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:krishimitra/screens/home.dart';
import 'package:krishimitra/screens/signin.dart';
import 'package:krishimitra/screens/first.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:krishimitra/screens/signup.dart';
import 'package:krishimitra/screens/plant.dart';
import 'package:krishimitra/screens/cattle.dart';
import 'package:krishimitra/services/api_service.dart';
import 'package:krishimitra/widgets/language_selector.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:krishimitra/providers/language_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'KrishiMitra',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // Hindi
            ],
            initialRoute: '/',
            onGenerateRoute: (settings) {
              if (settings.name == '/') {
                return MaterialPageRoute(
                  builder: (context) => FutureBuilder<bool>(
                    future: ApiService.isUserVerified(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      if (snapshot.hasData && snapshot.data == true) {
                        return HomePage();
                      }
                      
                      return FirstScreen();
                    },
                  ),
                );
              }
              return null;
            },
            routes: {
              '/home': (context) => HomePage(),
              '/signin': (context) => const LoginScreen(),
              '/first': (context) => FirstScreen(),
              '/signup': (context) => Signup(),
              '/plants': (context) => PlantScreen(),
              '/cattle': (context) => CattleScreen(),
            },
          );
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  WakelockPlus.enable();  // Keep the screen on
  runApp(const MyApp());
}
