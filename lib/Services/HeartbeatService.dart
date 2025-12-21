import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class HeartbeatService extends GetxController {
  static const String API_BASE_URL = 'https://dartotsu-bot.onrender.com'; // e.g., 'https://your-bot-server.com'
  static const Duration HEARTBEAT_INTERVAL = Duration(seconds: 30);
  
  Timer? _heartbeatTimer;
  String? _userId;
  
  @override
  void onInit() {
    super.onInit();
    _initUserId();
    startHeartbeat();
  }
  
  @override
  void onClose() {
    stopHeartbeat();
    super.onClose();
  }
  
  // Generate a unique user ID for this device
  Future<void> _initUserId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _userId = 'android_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _userId = 'ios_${iosInfo.identifierForVendor}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        _userId = 'windows_${windowsInfo.deviceId}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        _userId = 'linux_${linuxInfo.machineId}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        _userId = 'macos_${macInfo.systemGUID}';
      } else {
        _userId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      print('Error getting device ID: $e');
      _userId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  // Start sending heartbeats
  void startHeartbeat() {
    // Send initial heartbeat
    _sendHeartbeat();
    
    // Setup periodic heartbeats
    _heartbeatTimer = Timer.periodic(HEARTBEAT_INTERVAL, (_) {
      _sendHeartbeat();
    });
    
    print('💓 Heartbeat service started');
  }
  
  // Stop sending heartbeats
  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    print('💔 Heartbeat service stopped');
  }
  
  // Send heartbeat to backend
  Future<void> _sendHeartbeat() async {
    if (_userId == null) {
      await _initUserId();
    }
    
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/heartbeat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': _userId,
          'username': 'DartotsuUser', // Can be customized
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('💓 Heartbeat sent. Live users: ${data['liveCount']}');
      }
    } catch (e) {
      print('Error sending heartbeat: $e');
      // Don't throw - just log and continue
    }
  }
  
  // Pause heartbeat (e.g., when app goes to background)
  void pause() {
    _heartbeatTimer?.cancel();
    print('⏸️ Heartbeat paused');
  }
  
  // Resume heartbeat (e.g., when app comes to foreground)
  void resume() {
    if (_heartbeatTimer == null || !_heartbeatTimer!.isActive) {
      startHeartbeat();
    }
  }
}

// Global instance
var Heartbeat = Get.put(HeartbeatService());
