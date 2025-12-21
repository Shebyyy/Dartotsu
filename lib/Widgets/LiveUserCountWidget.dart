import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/LiveUserCountService.dart';

class LiveUserCountWidget extends StatelessWidget {
  final bool compact;
  
  const LiveUserCountWidget({
    Key? key,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    
    return Obx(() {
      final count = LiveUserCount.liveUserCount.value;
      final isLoading = LiveUserCount.isLoading.value;
      
      if (compact) {
        return _buildCompactView(theme, count, isLoading);
      }
      
      return _buildFullView(theme, count, isLoading);
    });
  }
  
  Widget _buildCompactView(ColorScheme theme, int count, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isLoading ? '...' : LiveUserCount.getFormattedCount(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: theme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'live',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: theme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFullView(ColorScheme theme, int count, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withOpacity(0.1),
            theme.primaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.people,
                  color: theme.primary,
                  size: 24,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isLoading ? '...' : LiveUserCount.getFormattedCount(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: theme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'users',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: theme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Currently watching on Dartotsu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: theme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!isLoading)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: theme.primary,
              ),
              onPressed: () => LiveUserCount.fetchLiveCount(),
            ),
        ],
      ),
    );
  }
}
