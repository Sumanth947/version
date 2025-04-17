import 'package:flutter/material.dart';
import '../services/version_service.dart';
class UpdateDialog extends StatefulWidget {
  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _showUpdateDialog = false;

  @override
  void initState() {
    super.initState();
    checkUpdate();
  }

  void checkUpdate() async {
    VersionService versionService = VersionService();
    bool needsUpdate = await versionService.checkForUpdate();

    if (needsUpdate) {
      setState(() {
        _showUpdateDialog = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showUpdateDialog
        ? AlertDialog(
            title: Text("Update Required"),
            content: Text("A new version of the app is available. Please update to continue."),
            actions: [
              TextButton(
                child: Text("Update Now"),
                onPressed: () {
                  // Add your app store link here
                  // Example: launch("https://play.google.com/store/apps/details?id=com.example.app");
                },
              ),
            ],
          )
        : SizedBox.shrink();
  }
}
