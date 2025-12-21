import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class LiveUserCountService extends GetxController {
  static const String API_BASE_URL = 'https://dartotsu-bot.onrender.com'; // Fixed: removed trailing slash
  
  var liveUserCount = 0.obs;
  var isLoading = false.obs;
  var lastUpdate = DateTime.now().obs;
  Timer? _updateTimer;

  @override
  void onInit() {
    super.onInit();
    fetchLiveCount();
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
        liveUserCount.value = data['count'] ?? 0;
        lastUpdate.value = DateTime.fromMillisecondsSinceEpoch(
          data['lastUpdate'] ?? DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      print('Error fetching live count: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getFormattedCount() {
    if (liveUserCount.value >= 1000) {
      return '${(liveUserCount.value / 1000).toStringAsFixed(1)}k';
    }
    return liveUserCount.value.toString();
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
