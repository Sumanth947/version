import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

class VersionService {
  static const String apiUrl = "http://192.168.0.213/int_2/check-version.php";
  static const String currentVersion = "1.0.0"; // Your current app version

  Future<bool> checkForUpdate() async {
    try {
      print('DETAILED Version Check Started');
      print(' API URL: $apiUrl');
      print(' Current App Version: $currentVersion');

      // Add timeout to the HTTP request
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print(' HTTP Request Timed Out');
          return http.Response('Timeout', 408);
        },
      );
      
      print('📡 FULL Response Details:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      if (response.statusCode != 200) {
        print(' HTTP Error: ${response.statusCode}');
        print('   Response Body: ${response.body}');
        return false;
      }

      // Defensive parsing to handle potential JSON issues
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (jsonError) {
        print(' JSON Parsing Error: $jsonError');
        print(' Problematic JSON: ${response.body}');
        return false;
      }

      print(' Parsed Response Data: $data');

      // More flexible error checking
      if (data is! Map) {
        print('Invalid response format. Expected Map, got ${data.runtimeType}');
        return false;
      }

      // Check for errors in the response
      if (data['status'] == 'error') {
        print(' Server Error: ${data['error']}');
        return false;
      }

      // Extract minimum version with additional checks
      String? minVersion = data['minimum_version'];
      
      if (minVersion == null) {
        print(' No minimum version found in response');
        print(' Full response data: $data');
        return false;
      }

      print(' Minimum Version from Server: $minVersion');

      // Compare versions
      bool needsUpdate = _compareVersions(currentVersion, minVersion);
      
      print(' Update Required: $needsUpdate');

      return needsUpdate;

    } on SocketException catch (e) {
      print(' Socket Exception: $e');
      print('   Possible network connectivity issues');
      return false;
    } on HttpException catch (e) {
      print(' HTTP Exception: $e');
      return false;
    } on FormatException catch (e) {
      print(' Format Exception: $e');
      return false;
    } catch (e, stackTrace) {
      print(' UNEXPECTED EXCEPTION during version check: $e');
      print(' Stack Trace: $stackTrace');
      return false;
    }
  }

  bool _compareVersions(String current, String minimum) {
    try {
      Version currentVer = Version.parse(current);
      Version minimumVer = Version.parse(minimum);
      
      bool updateNeeded = currentVer < minimumVer;
      
      print(' Detailed Version Comparison:');
      print('   Current Version (parsed): $currentVer');
      print('   Minimum Version (parsed): $minimumVer');
      print('   Numeric Comparison:');
      print('     Current Version Parts: ${currentVer.major}.${currentVer.minor}.${currentVer.patch}');
      print('     Minimum Version Parts: ${minimumVer.major}.${minimumVer.minor}.${minimumVer.patch}');
      print('   Update Needed: $updateNeeded');
      
      return updateNeeded;
    } catch (e) {
      print(' Version Parsing Error: $e');
      return false;
    }
  }
}