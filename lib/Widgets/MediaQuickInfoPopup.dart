import 'package:dartotsu/Adaptor/Media/Widgets/Chips.dart';
import 'package:dartotsu/DataClass/Media.dart';
import 'package:dartotsu/DataClass/SearchResults.dart';
import 'package:dartotsu/Functions/Extensions.dart';
import 'package:dartotsu/Functions/Function.dart';
import 'package:dartotsu/Preferences/IsarDataClasses/MediaSettings/MediaSettings.dart';
import 'package:dartotsu/Screens/Detail/MediaScreen.dart';
import 'package:dartotsu/Screens/Detail/Tabs/Info/Widgets/GenreWidget.dart';
import 'package:dartotsu/Screens/Search/SearchScreen.dart';
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
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: theme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          // Header with cover and title
          _buildHeader(theme, media, isAnime),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 160),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Stats Cards
                  _buildStatsCards(theme, media, isAnime),
                  
                  const SizedBox(height: 20),
                  
                  // Detailed Info Section
                  _buildDetailedInfoSection(theme, media, isAnime),
                  
                  const SizedBox(height: 24),
                  
                  // Synopsis
                  if (media.description != null && media.description!.isNotEmpty)
                    _buildSynopsisSection(theme, media),
                  
                  const SizedBox(height: 24),
                  
                  // Genres
                  if (media.genres.isNotEmpty) ...[
                    _buildGenresSection(theme, media),
                    const SizedBox(height: 24),
                  ],
                  
                  // Tags
                  if (media.tags.isNotEmpty) ...[
                    _buildTagsSection(theme, media),
                    const SizedBox(height: 24),
                  ],
                  
                  // Synonyms
                  if (media.synonyms.isNotEmpty) ...[
                    _buildSynonymsSection(theme, media),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          
          // Sticky Action Bar with gradient
          _buildStickyActionBar(theme, media, isAnime),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme theme, Media media, bool isAnime) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryContainer.withOpacity(0.3),
            theme.surface,
          ],
        ),
      ),
      child: Row(
        children: [
          // Media cover with shadow
          Hero(
            tag: 'cover-${media.id}',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadow.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  media.cover ?? '',
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryContainer,
                          theme.secondaryContainer,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: theme.onSurface.withOpacity(0.5),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Title and type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.userPreferredName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    color: theme.onSurface,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAnime 
                        ? theme.primary.withOpacity(0.15)
                        : theme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAnime ? theme.primary : theme.secondary,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAnime ? Icons.tv_rounded : Icons.menu_book_rounded,
                        size: 16,
                        color: isAnime ? theme.primary : theme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAnime ? 'ANIME' : 'MANGA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: isAnime ? theme.primary : theme.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: theme.onSurface,
              size: 28,
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.surfaceContainerHighest.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ColorScheme theme, Media media, bool isAnime) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme: theme,
              icon: Icons.star_rounded,
              label: 'Score',
              value: _formatScore(media.meanScore) ?? 'N/A',
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme: theme,
              icon: Icons.trending_up_rounded,
              label: 'Popularity',
              value: _formatNumber(media.popularity),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme: theme,
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              value: _formatNumber(media.favourites),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required ColorScheme theme,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              color: theme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: theme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfoSection(ColorScheme theme, Media media, bool isAnime) {
    String infoTotal = (media.anime?.nextAiringEpisode != null &&
            media.anime?.nextAiringEpisode != -1)
        ? "${media.anime?.nextAiringEpisode} | ${media.anime?.totalEpisodes ?? "~"}"
        : (media.anime?.totalEpisodes ?? media.manga?.totalChapters ?? "~").toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              theme: theme,
              icon: Icons.info_outline_rounded,
              title: 'Status',
              value: media.status?.toString().replaceAll("_", " "),
            ),
            _buildInfoRow(
              theme: theme,
              icon: isAnime ? Icons.tv_rounded : Icons.menu_book_rounded,
              title: isAnime ? 'Episodes' : 'Chapters',
              value: infoTotal,
            ),
            if (isAnime && media.anime?.episodeDuration != null)
              _buildInfoRow(
                theme: theme,
                icon: Icons.timer_outlined,
                title: 'Duration',
                value: _formatEpisodeDuration(media.anime?.episodeDuration),
              ),
            _buildInfoRow(
              theme: theme,
              icon: Icons.category_outlined,
              title: 'Format',
              value: media.format?.toString().replaceAll("_", " "),
            ),
            _buildInfoRow(
              theme: theme,
              icon: Icons.source_outlined,
              title: 'Source',
              value: media.source?.toString().replaceAll("_", " "),
            ),
            _buildInfoRow(
              theme: theme,
              icon: isAnime ? Icons.business_rounded : Icons.create_rounded,
              title: isAnime ? 'Studio' : 'Author',
              value: isAnime 
                  ? media.anime?.mainStudio?.name 
                  : (media.manga?.mediaAuthor?.name ?? media.anime?.mediaAuthor?.name),
            ),
            if (isAnime && media.anime?.season != null)
              _buildInfoRow(
                theme: theme,
                icon: Icons.calendar_today_rounded,
                title: 'Season',
                value: _formatSeason(media.anime?.season, media.anime?.seasonYear),
              ),
            if (media.startDate != null)
              _buildInfoRow(
                theme: theme,
                icon: Icons.play_circle_outline_rounded,
                title: 'Start Date',
                value: media.startDate!.getFormattedDate(),
              ),
            _buildInfoRow(
              theme: theme,
              icon: Icons.stop_circle_outlined,
              title: 'End Date',
              value: media.endDate?.getFormattedDate() ?? "Ongoing",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required ColorScheme theme,
    required IconData icon,
    required String title,
    String? value,
  }) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: theme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                color: theme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String? _formatScore(int? meanScore) {
    if (meanScore == null) return null;
    return "${(meanScore / 10).toStringAsFixed(1)}★";
  }

  String _formatNumber(int? number) {
    if (number == null) return 'N/A';
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String? _formatSeason(String? season, int? year) {
    if (season == null || year == null) return null;
    return "$season $year";
  }

  String _formatEpisodeDuration(int? episodeDuration) {
    if (episodeDuration == null) return '';
    final hours = episodeDuration ~/ 60;
    final minutes = episodeDuration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Widget _buildSynopsisSection(ColorScheme theme, Media media) {
    final document = html_parser.parse(media.description!);
    final String markdownContent = document.body?.text ?? "";
    
    if (markdownContent.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_rounded,
                  size: 20,
                  color: theme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Synopsis',
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  color: theme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: ExpandableText(
              markdownContent,
              maxLines: 4,
              expandText: 'Read more',
              collapseText: 'Show less',
              linkColor: theme.primary,
              style: TextStyle(
                fontSize: 14,
                color: theme.onSurface.withOpacity(0.85),
                height: 1.6,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresSection(ColorScheme theme, Media media) {
    if (media.genres.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.style_rounded,
                  size: 20,
                  color: theme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Genres',
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  color: theme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: media.genres.map((genre) {
              return _buildGenreChip(theme, genre);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(ColorScheme theme, String genre) {
    final searchType = widget.media.anime != null ? SearchType.ANIME : SearchType.MANGA;
    return InkWell(
      onTap: () {
        navigateToPage(
          context,
          SearchScreen(
            title: searchType,
            forceSearch: true,
            args: SearchResults(
              type: searchType,
              sort: "POPULARITY_DESC",
              genres: [genre],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryContainer,
              theme.secondaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          genre,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: theme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection(ColorScheme theme, Media media) {
    if (media.tags.isEmpty) return const SizedBox.shrink();
    
    // Show max 15 tags
    final displayTags = media.tags.take(15).toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.label_rounded,
                  size: 20,
                  color: theme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tags',
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  color: theme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayTags.map((tag) {
              return _buildTagChip(theme, tag);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(ColorScheme theme, String tag) {
    final searchType = widget.media.anime != null ? SearchType.ANIME : SearchType.MANGA;
    return InkWell(
      onTap: () {
        final tagParts = tag.split(" ");
        final searchTag = tagParts.length > 2
            ? tagParts.sublist(0, tagParts.length - 2).join(" ")
            : tag;
        
        navigateToPage(
          context,
          SearchScreen(
            title: searchType,
            forceSearch: true,
            args: SearchResults(
              type: searchType,
              sort: "POPULARITY_DESC",
              tags: [searchTag],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: theme.onSurface.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildSynonymsSection(ColorScheme theme, Media media) {
    if (media.synonyms.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.secondaryContainer.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.translate_rounded,
                  size: 20,
                  color: theme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Alternative Titles',
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  color: theme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...media.synonyms.map((synonym) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  synonym,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: theme.onSurface.withOpacity(0.85),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStickyActionBar(ColorScheme theme, Media media, bool isAnime) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.surface.withOpacity(0.0),
            theme.surface,
            theme.surface,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.outlineVariant.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _addToList(context, media),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: theme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                        shadowColor: theme.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Add to List',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _watchOrReadNow(context, media, isAnime),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.secondary,
                        foregroundColor: theme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                        shadowColor: theme.secondary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAnime ? Icons.play_arrow_rounded : Icons.menu_book_rounded,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAnime ? 'Watch' : 'Read',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // More Info button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openFullInfo(context, media),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primary,
                    side: BorderSide(color: theme.primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'More Info',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToList(BuildContext context, Media media) {
    Navigator.of(context).pop();
    context.currentService(listen: false).compactListEditor(context, media);
  }

  void _watchOrReadNow(BuildContext context, Media media, bool isAnime) {
    Navigator.of(context).pop();
    final mediaCopy = _copyMediaWithTab(media, 1);
    final tag = 'watch-read-${media.id}';
    navigateToPage(context, MediaInfoPage(mediaCopy, tag));
  }

  void _openFullInfo(BuildContext context, Media media) {
    Navigator.of(context).pop();
    final mediaCopy = _copyMediaWithTab(media, 0);
    final tag = 'info-${media.id}';
    navigateToPage(context, MediaInfoPage(mediaCopy, tag));
  }

  Media _copyMediaWithTab(Media media, int tabIndex) {
    return Media(
      id: media.id,
      idMAL: media.idMAL,
      name: media.name,
      nameRomaji: media.nameRomaji,
      userPreferredName: media.userPreferredName,
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
      isFav: media.isFav,
      anime: media.anime,
      manga: media.manga,
      relations: media.relations,
      characters: media.characters,
      staff: media.staff,
      recommendations: media.recommendations,
      prequel: media.prequel,
      sequel: media.sequel,
      users: media.users,
      source: media.source,
      userListId: media.userListId,
      userProgress: media.userProgress,
      userStatus: media.userStatus,
      userScore: media.userScore,
      settings: MediaSettings(
        navBarIndex: tabIndex,
        lastUsedSource: media.settings.lastUsedSource,
        viewType: media.settings.viewType,
        isReverse: media.settings.isReverse,
        server: media.settings.server,
        selectedScanlators: media.settings.selectedScanlators,
        playerSetting: media.settings.playerSettings,
        readerSetting: media.settings.readerSettings,
      ),
    );
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
    ),
    builder: (context) => MediaQuickInfoPopup(media: media),
  );
}
