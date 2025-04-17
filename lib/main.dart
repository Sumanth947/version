import 'package:flutter/material.dart';
import './services/version_service.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  void checkForUpdate() async {
    try {
      VersionService versionService = VersionService();
      bool needsUpdate = await versionService.checkForUpdate();

      print('💡 Version Check Result: needsUpdate = $needsUpdate');

      if (needsUpdate) {
        // Use microtask to ensure this runs after build
        Future.microtask(() {
          showUpdateDialog();
        });
      }
    } catch (e) {
      print('❌ Error during version check: $e');
      // Optionally, you could log this error or show a generic error dialog
    }
  }

  Future<void> _launchPlayStore() async {
    final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.whatsapp');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        print('Could not launch $url');
        // Optionally show a snackbar or toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open Play Store'))
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Update Required"),
        content: Text("A new version of the app is available. Please update to continue."),
        actions: [
          TextButton(
            child: Text("Update Now"),
            onPressed: _launchPlayStore,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My App")),
      body: Center(child: Text("Welcome to MyApp")),
    );
  }
}