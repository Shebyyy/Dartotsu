import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class LiveUserCountService extends GetxController {
  static const String API_BASE_URL = 'https://dartotsu-bot.onrender.com'; // e.g., 'https://your-bot-server.com'
  
  // Reactive state
  var totalUsers = 0.obs;      // Total app users (heartbeat)
  var watchingUsers = 0.obs;   // Users watching/reading (Discord RPC)
  var browsingUsers = 0.obs;   // Total Discord users
  var isLoading = false.obs;
  var lastUpdate = DateTime.now().obs;
  
  Timer? _updateTimer;
  
  @override
  void onInit() {
    super.onInit();
    fetchLiveCount();
    // Update every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchLiveCount();
    });
  }
  
  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }
  
  Future<void> fetchLiveCount() async {
    try {
      isLoading.value = true;
      
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/live-count'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        totalUsers.value = data['total'] ?? 0;
        watchingUsers.value = data['watching'] ?? 0;
        browsingUsers.value = data['browsing'] ?? 0;
        lastUpdate.value = DateTime.fromMillisecondsSinceEpoch(
          data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      print('Error fetching live count: $e');
      // Keep previous counts on error
    } finally {
      isLoading.value = false;
    }
  }
  
  // Formatted count helpers
  String getFormattedTotal() {
    return _formatCount(totalUsers.value);
  }
  
  String getFormattedWatching() {
    return _formatCount(watchingUsers.value);
  }
  
  String getFormattedBrowsing() {
    return _formatCount(browsingUsers.value);
  }
  
  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
  
  String getTimeSinceUpdate() {
    final diff = DateTime.now().difference(lastUpdate.value);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
}

var LiveUserCount = Get.put(LiveUserCountService());
