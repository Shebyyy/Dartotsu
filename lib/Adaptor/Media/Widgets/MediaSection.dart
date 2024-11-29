import 'package:flutter/material.dart';

import '../../../DataClass/Media.dart';
import '../MediaAdaptor.dart';

Widget MediaSection({
  required BuildContext context,
  required int type,
  required String title,
  bool isLarge = false,
  List<Media>? mediaList,
  List<Widget>? customNullListIndicator,
  ScrollController? scrollController,
  Function(int index, Media media)? onMediaTap,
}) {
  var theme = Theme.of(context);

  Widget buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title Text
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Arrow Icon
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(3.14),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return SizedBox(
      height: 250,
      child: Center(
        child: customNullListIndicator?.isNotEmpty ?? false
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: customNullListIndicator!,
              )
            : const Text(
                'Nothing here',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget buildMediaContent() {
    return mediaList == null
        ? const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : mediaList.isEmpty
            ? buildEmptyState()
            : MediaAdaptor(
                type: type,
                mediaList: mediaList,
                isLarge: isLarge,
                scrollController: scrollController,
                onMediaTap: onMediaTap,
              );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildTitleRow(),
      const SizedBox(height: 8),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: buildMediaContent(),
      ),
    ],
  );
}
