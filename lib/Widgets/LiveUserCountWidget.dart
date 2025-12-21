import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/LiveUserCountService.dart';

class LiveUserCountWidget extends StatelessWidget {
  final bool compact;
  final bool showWatching; // Show watching count instead of total
  
  const LiveUserCountWidget({
    Key? key,
    this.compact = false,
    this.showWatching = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    
    return Obx(() {
      final isLoading = LiveUserCount.isLoading.value;
      
      if (compact) {
        return _buildCompactView(theme, isLoading);
      }
      
      return _buildFullView(theme, isLoading);
    });
  }
  
  Widget _buildCompactView(ColorScheme theme, bool isLoading) {
    final total = LiveUserCount.totalUsers.value;
    final watching = LiveUserCount.watchingUsers.value;
    
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
          // Indicator dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: showWatching ? Colors.orange : Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (showWatching ? Colors.orange : Colors.green).withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Count
          Text(
            isLoading 
                ? '...' 
                : showWatching 
                    ? LiveUserCount.getFormattedWatching()
                    : LiveUserCount.getFormattedTotal(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: theme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          // Label
          Text(
            showWatching ? 'watching' : 'online',
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
  
  Widget _buildFullView(ColorScheme theme, bool isLoading) {
    final total = LiveUserCount.totalUsers.value;
    final watching = LiveUserCount.watchingUsers.value;
    
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
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: theme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Live Activity',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              if (!isLoading)
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.primary,
                    size: 18,
                  ),
                  onPressed: () => LiveUserCount.fetchLiveCount(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Total Online
              _buildStatColumn(
                theme,
                Icons.circle,
                Colors.green,
                isLoading ? '...' : LiveUserCount.getFormattedTotal(),
                'Online',
              ),
              
              // Vertical divider
              Container(
                height: 40,
                width: 1,
                color: theme.onSurface.withOpacity(0.2),
              ),
              
              // Currently Watching
              _buildStatColumn(
                theme,
                Icons.play_circle_filled,
                Colors.orange,
                isLoading ? '...' : LiveUserCount.getFormattedWatching(),
                'Watching',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(
    ColorScheme theme,
    IconData icon,
    Color iconColor,
    String count,
    String label,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              count,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: theme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: theme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// Specialized widget for showing both counts in compact form
class DualLiveCountWidget extends StatelessWidget {
  const DualLiveCountWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    
    return Obx(() {
      final isLoading = LiveUserCount.isLoading.value;
      final total = LiveUserCount.totalUsers.value;
      final watching = LiveUserCount.watchingUsers.value;
      
      // *** CHANGE: Changed Column to Row for side-by-side layout ***
      return Row(
        children: [
          // Online count
          _buildCompactStat(
            theme,
            Colors.green,
            isLoading ? '...' : LiveUserCount.getFormattedTotal(),
            'online',
          ),
          // *** CHANGE: Added horizontal spacing ***
          const SizedBox(width: 8),
          // Watching count
          _buildCompactStat(
            theme,
            Colors.orange,
            isLoading ? '...' : LiveUserCount.getFormattedWatching(),
            'watching',
          ),
        ],
      );
    });
  }
  
  Widget _buildCompactStat(ColorScheme theme, Color color, String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: theme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: theme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
