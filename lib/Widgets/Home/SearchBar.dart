import 'package:cached_network_image/cached_network_image.dart';
import 'package:dantotsu/Functions/Extensions.dart';
import 'package:dantotsu/Screens/Login/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../Animation/SlideUpAnimation.dart';
import '../../Functions/Function.dart';
import '../../Screens/Settings/SettingsBottomSheet.dart';
import '../../api/Anilist/Anilist.dart';
import 'AvtarWidget.dart';
import 'NotificationBadge.dart';

class MediaSearchBar extends StatelessWidget {
  final String title;

  const MediaSearchBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 36.statusBar(), 32, 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => navigateToPage(context, const LoginScreen())
              ,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: title,
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: theme.onSurface,
                    ),
                    suffixIcon: Icon(Icons.search, color: theme.onSurface),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: theme.primaryContainer,
                        width: 1.0,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                  ),
                  readOnly: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
           GestureDetector(
            child: const AvatarWidget(icon: Icons.settings),
            onTap: () => settingsBottomSheet(context),
          )
        ],
      ),
    );
  }
}