import 'package:dantotsu/Functions/Function.dart';
import 'package:dantotsu/Screens/Info/Tabs/Watch/Widgets/SourceSelector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../../DataClass/Episode.dart';
import '../../../../DataClass/Media.dart';
import '../../../../Preferences/PrefManager.dart';
import '../../../../Preferences/Preferences.dart';
import '../../../../Widgets/ScrollConfig.dart';
import '../../../../api/Mangayomi/Model/Source.dart';
import '../../Widgets/Releasing.dart';
import 'WatchPageViewModel.dart';

class WatchPage extends ConsumerStatefulWidget {
  final media mediaData;

  const WatchPage({super.key, required this.mediaData});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WatchPageState();
}

class _WatchPageState extends ConsumerState<WatchPage> {
  Source? source;
  final _viewModel = Get.put(WatchPageViewModel());

  @override
  void initState() {
    super.initState();
    _viewModel.reset();
  }

  void onSourceChange(Source source) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        this.source = source;
        _viewModel.searchMedia(source, widget.mediaData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...releasingIn(widget.mediaData, context),
        _buildWithPadding([
          ..._buildYouTubeButton(),
          Obx(
            () => Text(
              _viewModel.status.value ?? '',
              style: TextStyle(
                  color: theme.onSurface, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SourceSelector(
            currentSource: source,
            onSourceChange: onSourceChange,
            mediaData: widget.mediaData,
          ),
          const SizedBox(height: 16),
          _buildWrongTitle(),
        ]),
        _buildEpisodeList(),
      ],
    );
  }

  Widget _buildWithPadding(List<Widget> widgets) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _buildEpisodeList() {
    return Obx(() {
      var chapters = _viewModel.episodeList.value;

      if (chapters == null || chapters.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final total = chapters.length;
      final divisions = total / 10;
      var chunkSize = (divisions < 25)
          ? 25
          : (divisions < 50)
          ? 50
          : 100;
      List<List<Episode>> chunks = [];
      for (var i = 0; i < chapters.length; i += chunkSize) {
        chunks.add(chapters.sublist(i,
            i + chunkSize > chapters.length ? chapters.length : i + chunkSize));
      }

      final RxInt selectedChunkIndex = 0.obs;
      String targetEpisodeNumber = widget.mediaData.userProgress.toString();

      for (var chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
        if (chunks[chunkIndex]
            .any((episode) => episode.number == targetEpisodeNumber)) {
          selectedChunkIndex.value = chunkIndex;
          break;
        }
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScrollConfig(
            context,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: List.generate(chunks.length, (index) {
                    String f = chunks[index].first.number;
                    String l = chunks[index].last.number;
                    return Padding(
                      padding:  EdgeInsets.only(left: index == 0 ? 32.0 : 6.0, right: index == chunks.length - 1 ? 32.0 : 6.0),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text('$f - $l',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            )),
                        selected: selectedChunkIndex.value == index,
                        onSelected: (bool selected) {
                          if (selected) {
                            selectedChunkIndex.value = index;
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          // List of episodes
          Flexible(
            fit: FlexFit.loose,
            child: Obx(() => ListView.builder(
                  shrinkWrap: true,
                  itemCount: chunks[selectedChunkIndex.value].length,
                  itemBuilder: (context, index) {
                    var episode = chunks[selectedChunkIndex.value][index];
                    return GestureDetector(
                      onTap: () async {
                        // Handle tap action
                      },
                      child: ListTile(
                        title: Text(episode.title ?? ''),
                        subtitle: Text(episode.number),
                      ),
                    );
                  },
                )),
          ),
        ],
      );
    });
  }

  Widget _buildWrongTitle() {
    var theme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () async =>
              _viewModel.wrongTitle(context, source!, widget.mediaData),
          child: Text(
            'Wrong title?',
            style: TextStyle(
              color: theme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: theme.secondary,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildYouTubeButton() {
    return [
      if (widget.mediaData.anime?.youtube != null &&
          PrefManager.getVal(PrefName.showYtButton)) ...[
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () =>
                openLinkInBrowser(widget.mediaData.anime!.youtube!),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Play on YouTube',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    ];
  }
}
/*
var dialog = CustomBottomDialog(
  title: 'Select episode',
  viewList: [
    FutureBuilder<List<Video>>(
      future: getVideo(
          source: source!,
          url: chapters[index].url ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No episodes found.'));
        }
        var episodeList = snapshot.data!;
        return Column(
          children: [
            for (var episode in episodeList)
              ListTile(
                title: Text(episode.quality),
                onTap: () {
                  openLinkInBrowser(episode.url);
                },
              ),
          ],
        );
      },
    ),
  ],
);
showCustomBottomDialog(context, dialog);*/
