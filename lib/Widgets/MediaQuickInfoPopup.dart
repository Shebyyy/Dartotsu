import 'package:dartotsu/Adaptor/Media/Widgets/Chips.dart';
import 'package:dartotsu/DataClass/Media.dart';
import 'package:dartotsu/DataClass/SearchResults.dart';
import 'package:dartotsu/Functions/Function.dart';
import 'package:dartotsu/Preferences/IsarDataClasses/MediaSettings/MediaSettings.dart';
import 'package:dartotsu/Screens/Detail/MediaScreen.dart';
import 'package:dartotsu/Screens/Detail/Tabs/Info/Widgets/GenreWidget.dart';
import 'package:dartotsu/Theme/LanguageSwitcher.dart';
import 'package:dartotsu/Theme/ThemeManager.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;

class MediaQuickInfoPopup extends StatefulWidget {
  final Media media;

  const MediaQuickInfoPopup({
    super.key,
    required this.media,
  });

  @override
  State<MediaQuickInfoPopup> createState() => _MediaQuickInfoPopupState();
}

class _MediaQuickInfoPopupState extends State<MediaQuickInfoPopup> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final media = widget.media;
    final isAnime = media.anime != null;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.onSurface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header with close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              children: [
                // Media cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    media.cover ?? '',
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 80,
                      color: theme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported,
                        color: theme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Title and close button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media.userPreferredName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAnime ? 'Anime' : 'Manga',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.onSurface.withOpacity(0.7),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: theme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Info Section
                      _buildKeyInfoSection(theme, media),
                      
                      const SizedBox(height: 24),
                      
                      // Synopsis
                      _buildSynopsisSection(theme, media),
                      
                      const SizedBox(height: 24),
                      
                      // Synonyms
                      if (media.synonyms.isNotEmpty) ...[
                        _buildSynonymsSection(theme, media),
                        const SizedBox(height: 24),
                      ],
                      
                      // Genres
                      if (media.genres.isNotEmpty) ...[
                        _buildGenresSection(theme, media),
                        const SizedBox(height: 24),
                      ],
                      
                      // Tags
                      if (media.tags.isNotEmpty) ...[
                        _buildTagsSection(theme, media),
                        const SizedBox(height: 120), // Space for sticky action bar
                      ],
                    ],
                  ),
                ),
              ),
          
          // Sticky Action Bar
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: theme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _buildActionButtons(theme, media, isAnime),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfoSection(ColorScheme theme, Media media) {
    bool isAnime = media.anime != null;
    
    String infoTotal = (media.anime?.nextAiringEpisode != null &&
            media.anime?.nextAiringEpisode != -1)
        ? "${media.anime?.nextAiringEpisode} | ${media.anime?.totalEpisodes ?? "~"}"
        : (media.anime?.totalEpisodes ?? media.manga?.totalChapters ?? "~").toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            theme: theme,
            title: getString.meanScore,
            value: _formatScore(media.meanScore),
          ),
          _buildInfoRow(
            theme: theme,
            title: getString.status,
            value: media.status?.toString().replaceAll("_", " "),
          ),
          _buildInfoRow(
            theme: theme,
            title: "${getString.total} ${isAnime ? getString.totalEpisodes : getString.totalChapters}",
            value: infoTotal,
          ),
          _buildInfoRow(
            theme: theme,
            title: getString.format,
            value: media.format?.toString().replaceAll("_", " "),
          ),
          if (media.startDate != null)
            _buildInfoRow(
              theme: theme,
              title: getString.startDate,
              value: media.startDate!.getFormattedDate(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required ColorScheme theme,
    required String title,
    String? value,
  }) {
    if (value == null || value.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _formatScore(int? meanScore) {
    if (meanScore == null) return null;
    return "${(meanScore / 10).toStringAsFixed(1)}%";
  }

  Widget _buildSynopsisSection(ColorScheme theme, Media media) {
    if (media.description == null || media.description!.isEmpty) {
      return Container();
    }
    
    // Parse HTML content like the InfoPage does
    final document = html_parser.parse(media.description!);
    final String markdownContent = document.body?.text ?? "";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getString.synopsis,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ExpandableText(
          markdownContent,
          maxLines: 3,
          expandText: getString.expandText,
          collapseText: getString.collapseText,
          style: TextStyle(
            fontSize: 14,
            color: theme.onSurface.withOpacity(0.8),
            height: 1.5,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildSynonymsSection(ColorScheme theme, Media media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getString.synonyms,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ChipsWidget(chips: [..._generateSynonyms(media.synonyms)]),
      ],
    );
  }

  List<ChipData> _generateSynonyms(List<String> labels) {
    return labels.map((label) {
      return ChipData(label: label, action: () {});
    }).toList();
  }

  Widget _buildGenresSection(ColorScheme theme, Media media) {
    final searchType = media.anime != null ? SearchType.ANIME : SearchType.MANGA;
    return GenreWidget(context, media.genres, searchType);
  }

  Widget _buildTagsSection(ColorScheme theme, Media media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getString.tags,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ChipsWidget(chips: [..._generateChips(media.tags)]),
      ],
    );
  }

  List<ChipData> _generateChips(List<String> labels) {
    final searchType = widget.media.anime != null ? SearchType.ANIME : SearchType.MANGA;
    return labels.map((label) {
      return ChipData(
        label: label,
        action: () => navigateToPage(
          context,
          SearchScreen(
            title: searchType,
            forceSearch: true,
            args: SearchResults(
              type: searchType,
              sort: "POPULARITY_DESC",
              tags: [
                label
                    .split(" ")
                    .sublist(0, label.split(" ").length - 2)
                    .join(" ")
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildActionButtons(ColorScheme theme, Media media, bool isAnime) {
    return Column(
      children: [
        // Primary action buttons
        Row(
          children: [
            // Add to List button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addToList(context, media),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add to List',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Watch/Read Now button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _watchOrReadNow(context, media, isAnime),
                icon: Icon(isAnime ? Icons.play_arrow : Icons.menu_book, size: 18),
                label: Text(
                  isAnime ? 'Watch Now' : 'Read Now',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondary,
                  foregroundColor: theme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Open Full View button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openFullView(context, media),
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text(
              'Open Full View',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primary,
              side: BorderSide(color: theme.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addToList(BuildContext context, Media media) {
    Navigator.of(context).pop();
    // Use the existing service to add to list
    context.currentService(listen: false).compactListEditor(context, media);
  }

  void _watchOrReadNow(BuildContext context, Media media, bool isAnime) {
    Navigator.of(context).pop();
    // Create a copy of media with modified nav bar index to start on Watch/Read tab
    final mediaCopy = Media(
      id: media.id,
      nameRomaji: media.nameRomaji,
      userPreferredName: media.userPreferredName,
      anime: media.anime,
      manga: media.manga,
      // Copy all other relevant fields
      name: media.name,
      cover: media.cover,
      banner: media.banner,
      description: media.description,
      status: media.status,
      format: media.format,
      genres: media.genres,
      tags: media.tags,
      synonyms: media.synonyms,
      meanScore: media.meanScore,
      popularity: media.popularity,
      favourites: media.favourites,
      startDate: media.startDate,
      endDate: media.endDate,
      isAdult: media.isAdult,
      // Create settings with navBarIndex set to 1 (Watch/Read tab)
      settings: MediaSettings(
        navBarIndex: 1,
        lastUsedSource: media.settings.lastUsedSource,
        viewType: media.settings.viewType,
        isReverse: media.settings.isReverse,
        server: media.settings.server,
        selectedScanlators: media.settings.selectedScanlators,
        playerSetting: media.settings.playerSettings,
        readerSetting: media.settings.readerSettings,
      ),
    );
    
    final tag = 'watch-${media.id}';
    navigateToPage(context, MediaInfoPage(mediaCopy, tag));
  }

  void _openFullView(BuildContext context, Media media) {
    Navigator.of(context).pop();
    // Create a copy of media with modified nav bar index to start on Info tab
    final mediaCopy = Media(
      id: media.id,
      nameRomaji: media.nameRomaji,
      userPreferredName: media.userPreferredName,
      anime: media.anime,
      manga: media.manga,
      // Copy all other relevant fields
      name: media.name,
      cover: media.cover,
      banner: media.banner,
      description: media.description,
      status: media.status,
      format: media.format,
      genres: media.genres,
      tags: media.tags,
      synonyms: media.synonyms,
      meanScore: media.meanScore,
      popularity: media.popularity,
      favourites: media.favourites,
      startDate: media.startDate,
      endDate: media.endDate,
      isAdult: media.isAdult,
      // Create settings with navBarIndex set to 0 (Info tab)
      settings: MediaSettings(
        navBarIndex: 0,
        lastUsedSource: media.settings.lastUsedSource,
        viewType: media.settings.viewType,
        isReverse: media.settings.isReverse,
        server: media.settings.server,
        selectedScanlators: media.settings.selectedScanlators,
        playerSetting: media.settings.playerSettings,
        readerSetting: media.settings.readerSettings,
      ),
    );
    
    final tag = 'detail-${media.id}';
    navigateToPage(context, MediaInfoPage(mediaCopy, tag));
  }
}

void showMediaQuickInfoPopup(BuildContext context, Media media) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    enableDrag: true,
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
    ),
    builder: (context) => MediaQuickInfoPopup(media: media),
  );
}
