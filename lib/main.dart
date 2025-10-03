// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/font_size_provider.dart';
import 'package:logging/logging.dart';

// Import semua file screen
import 'screens/beranda_screen.dart';
import 'screens/rubrik_screen.dart';
import 'screens/cari_screen.dart';
import 'screens/bookmark_screen.dart'; // Import bookmark screen
import 'screens/popular_screen.dart'; // Import popular screen
import 'screens/kirim_tulisan_screen.dart';
import 'screens/offline_screen.dart'; // Import offline screen
// Network test screen removed

void main() {
  // Set up logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('Stack trace: ${record.stackTrace}');
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'BacaPetra',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
            ).copyWith(secondary: Colors.amber.shade800),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              elevation: 1,
            ),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
            ).copyWith(secondary: Colors.amber.shade700),
          ),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Tambahkan PopularScreen ke daftar widget (BookmarkScreen dipindah ke drawer)
  static const List<Widget> _widgetOptions = <Widget>[
    BerandaScreen(),
    RubrikScreen(),
    CariScreen(),
    PopularScreen(),
    KirimTulisanScreen(),
    // NetworkTestScreen() removed
  ];

  // Judul untuk halaman (BookmarkScreen dipindah ke drawer)
  static const List<String> _titleOptions = <String>[
    'Beranda',
    'Rubrik',
    'Cari Tulisan',
    'Populer',
    'Kirim Tulisan',
    // 'Network Test' removed
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleOptions[_selectedIndex]),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],

      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'BacaPetra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Menjadi Baik dengan Membaca',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.offline_pin),
              title: const Text('Artikel Offline'),
              subtitle: const Text('Baca tanpa internet'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OfflineScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmarks),
              title: const Text('Tersimpan'),
              subtitle: const Text('Artikel yang disimpan'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookmarkScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'BacaPetra',
                  applicationVersion: '1.1.0',
                  applicationLegalese: '© 2025 Yayasan Klub Buku Petra',
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Platform literasi digital untuk komunitas sastra Indonesia. '
                      'Temukan, baca, dan bagikan karya-karya menarik dari berbagai penulis.\n\n'
                      'Dioperasikan oleh Yayasan Klub Buku Petra, '
                      'organisasi nirlaba yang telah berkontribusi untuk komunitas literasi '
                      'Indonesia selama hampir 7 tahun.\n\n'
                      'Developed by Chrisnov IT Solutions',
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        // Item navigasi (BookmarkScreen dipindah ke drawer)
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Rubrik'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Populer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Kirim Tulisan',
          ),
          // NetworkTestScreen() removed
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
