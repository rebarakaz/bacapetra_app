// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
    PopularScreen(),
    KirimTulisanScreen(),
  ];

  // Judul untuk halaman (BookmarkScreen dipindah ke drawer)
  static const List<String> _titleOptions = <String>[
    'Beranda',
    'Rubrik',
    'Populer',
    'Menulis',
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CariScreen()),
              );
            },
            tooltip: 'Cari Tulisan',
          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.menu_book,
                            color: Theme.of(context).colorScheme.primary,
                            size: 35,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BacaPetra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Menjadi Baik dengan Membaca',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
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
              title: const Text('Bookmark'),
              subtitle: const Text('Artikel favorit Anda'),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Media Sosial',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Website'),
              onTap: () async {
                final uri = Uri.parse('https://www.bacapetra.co');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Instagram'),
              onTap: () async {
                final uri = Uri.parse('https://www.instagram.com/klubbukupetra');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
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
                  applicationVersion: '1.2.0',
                  applicationLegalese: '© 2025 Yayasan Klub Buku Petra',
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Platform literasi digital untuk komunitas sastra Indonesia. '
                      'BacaPetra hadir sebagai ruang bagi para penulis dan pembaca untuk saling berbagi gagasan, rasa, dan karya.\n\n'
                      'Yayasan Klub Buku Petra adalah organisasi nirlaba di Ruteng, Flores, NTT '
                      'yang berfokus pada pengembangan literasi, budaya, dan pendidikan di Indonesia Timur.\n\n'
                      'Developed by Chrisnov IT Solutions\n'
                      '© 2025 Yayasan Klub Buku Petra',
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
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Populer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Menulis',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
