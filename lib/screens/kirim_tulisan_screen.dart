// lib/screens/kirim_tulisan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/html_parser.dart' as dom;
import 'package:html/dom.dart' as html;
import '../models/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'webview_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../utils/html_utils.dart';
import '../utils/constants.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';

// fetchPageContent() function has been moved to ApiService

class KirimTulisanScreen extends StatefulWidget {
  const KirimTulisanScreen({super.key});

  @override
  State<KirimTulisanScreen> createState() => _KirimTulisanScreenState();
}

class _KirimTulisanScreenState extends State<KirimTulisanScreen> {
  late Future<Post> futurePage;

  @override
  void initState() {
    super.initState();
    futurePage = ApiService.fetchPageContent(AppConstants.kirimTulisanPageId); // Call from ApiService
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post>(
      future: futurePage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Kirim Tulisan'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Kirim Tulisan'),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          Post pageData = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Kirim Tulisan'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tampilkan judul halaman sebagai header
                  Text(
                    unescape.convert(pageData.title),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Gunakan flutter_html untuk merender kontennya
                  Consumer<FontSizeProvider>(
                    builder: (context, fontSizeProvider, child) {
                      return Html(
                        data: unescape.convert(pageData.content),
                        style: {
                          // Aturan ini akan menyembunyikan tag judul dari konten
                          "h1": Style(
                            display: Display.none,
                          ),
                          "body": Style(fontSize: FontSize(18.0 * fontSizeProvider.fontSizeScale), lineHeight: LineHeight.number(1.5)),
                          "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                          "hr": Style(
                            margin: Margins.symmetric(vertical: 24.0),
                            border: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
                          ),
                          "a": Style(color: Colors.blue.shade800, textDecoration: TextDecoration.none),
                          "ul, ol": Style(
                            padding: HtmlPaddings.only(left: 25),
                          ),
                          "li": Style(
                            margin: Margins.only(bottom: 8.0),
                            listStyleType: ListStyleType.disc, // Bisa juga .circle atau .square
                          ),
                        },
                        onLinkTap: (String? url, Map<String, String> attributes, html.Element? element) async {
                          final currentContext = context;
                          // Cek dulu apakah URL-nya tidak null atau kosong
                          if (url != null && await canLaunchUrl(Uri.parse(url))) {
                            // Navigasi ke WebviewScreen untuk membuka URL di dalam app
                            if (currentContext.mounted) {
                              Navigator.push(
                                currentContext,
                                MaterialPageRoute(
                                  builder: (context) => WebviewScreen(
                                    url: url,
                                    title: 'Kirim Tulisan',
                                  ),
                                ),
                              );
                            }
                          } else {
                            // Jika gagal, tampilkan snackbar
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(content: Text('Could not launch $url')),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Kirim Tulisan'),
            ),
            body: Center(child: Text('Konten tidak ditemukan.')),
          );
        }
      },
    );
  }
}
