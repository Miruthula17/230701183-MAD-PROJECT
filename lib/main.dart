import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/jobs_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/search_provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/board_screen.dart';
import 'screens/add_job_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const JobGenieApp(),
    ),
  );
}

class JobGenieApp extends StatelessWidget {
  const JobGenieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobGenie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0A66C2),
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F2EF),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF3F2EF),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF191919),
            letterSpacing: -0.5,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF0A66C2),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEBEBEB), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A66C2),
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEBEBEB),
          labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFFFFFFFF),
          contentTextStyle: const TextStyle(color: const Color(0xFF191919)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    SizedBox(), // Placeholder for Add button
    BoardScreen(),
    ProfileScreen(),
  ];

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFEBEBEB).withValues(alpha: 0.5),
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFF0A66C2).withValues(alpha: 0.2),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddJobScreen()),
              );
              return;
            }
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.grey[600]),
              selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF70B5F9)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined, color: Colors.grey[600]),
              selectedIcon: const Icon(Icons.search_rounded, color: Color(0xFF70B5F9)),
              label: 'Search',
            ),
            const NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0A66C2), size: 30),
              selectedIcon: Icon(Icons.add_circle_rounded, color: Color(0xFF0A66C2), size: 30),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.view_kanban_outlined, color: Colors.grey[600]),
              selectedIcon: const Icon(Icons.view_kanban_rounded, color: Color(0xFF70B5F9)),
              label: 'Track',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Colors.grey[600]),
              selectedIcon: const Icon(Icons.person_rounded, color: Color(0xFF70B5F9)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
