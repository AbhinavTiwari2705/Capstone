import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:krishimitra/screens/cattle.dart';
import 'package:krishimitra/screens/plant.dart';
import 'package:krishimitra/screens/news_screen.dart';
import 'package:krishimitra/screens/marketplace_screen.dart';
import 'package:krishimitra/widgets/language_selector.dart';
import 'package:krishimitra/services/api_service.dart';
import 'package:krishimitra/screens/signin.dart';
import 'package:krishimitra/screens/signup.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    final isVerified = await ApiService.isUserVerified();
    setState(() {
      _isVerified = isVerified;
    });
    if (!isVerified) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await ApiService.clearTokens();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildMainContent();
      case 1:
        return CattleScreen();
      case 2:
        return PlantScreen();
      case 3:
        return NewsScreen();
      default:
        return _buildMainContent();
    }
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green[50]!, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/playstore.png', // Updated to use the correct image path
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.welcome,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.welcomeSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildFeatureCard(
                  icon: Icons.pets,
                  title: AppLocalizations.of(context)!.cattleHealth,
                  color: Colors.brown[400]!,
                  onTap: () => _onItemTapped(1),
                ),
                _buildFeatureCard(
                  icon: Icons.local_florist,
                  title: AppLocalizations.of(context)!.plantHealth,
                  color: Colors.green[400]!,
                  onTap: () => _onItemTapped(2),
                ),
                _buildFeatureCard(
                  icon: Icons.article,
                  title: AppLocalizations.of(context)!.agricultureNews,
                  color: Colors.blue[400]!,
                  onTap: () => _onItemTapped(3),
                ),
                _buildFeatureCard(
                  icon: Icons.store,
                  title: AppLocalizations.of(context)!.marketplace,
                  color: Colors.orange[400]!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MarketplaceScreen()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              AppLocalizations.of(context)!.getStarted,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          LanguageSelector(),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: AppLocalizations.of(context)!.logout,
          ),
        ],
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: AppLocalizations.of(context)!.cattle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: AppLocalizations.of(context)!.plant,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: AppLocalizations.of(context)!.news,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'KrishiMitra',
    theme: ThemeData(
      primarySwatch: Colors.green,
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/cattle': (context) => CattleScreen(),
      '/plants': (context) => PlantScreen(),
      '/signin': (context) => LoginScreen(),
      '/signup': (context) => Signup(),
      '/news': (context) => NewsScreen(),
    },
    supportedLocales: [
      Locale('en', 'US'), // English, no country code
    ],
  ));
}