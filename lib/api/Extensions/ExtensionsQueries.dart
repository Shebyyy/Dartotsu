import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dantotsu/DataClass/Media.dart';
import 'package:dantotsu/DataClass/SearchResults.dart';
import 'package:dantotsu/Functions/Function.dart';
import 'package:dantotsu/Functions/string_extensions.dart';
import 'package:dantotsu/api/Sources/Eval/dart/model/m_manga.dart';
import 'package:dantotsu/api/Sources/Model/Source.dart';
import 'package:get/get.dart';

import '../../DataClass/Author.dart';
import '../../Preferences/PrefManager.dart';
import '../../Screens/Detail/Tabs/Watch/Anime/AnimeParser.dart';
import '../../Screens/Detail/Tabs/Watch/Manga/MangaParser.dart';
import '../../Services/Api/Queries.dart';
import '../../main.dart';
import '../Sources/Search/get_detail.dart';
import 'ExtensionsData.dart';

part 'ExtensionsQueries/GetHomePageData.dart';
part 'ExtensionsQueries/GetMediaDetails.dart';
part 'ExtensionsQueries/GetUserData.dart';

class ExtensionsQueries extends Queries {
  @override
  Future<Map<String, List<Media>>> getAnimeList() {
    // not needed
    throw UnimplementedError();
  }

  @override
  Future<List<Media>> getCalendarData() {
    // TODO: implement getCalendarData
    throw UnimplementedError();
  }

  @override
  Future<bool>? getGenresAndTags() {
    // TODO: implement getGenresAndTags
    throw UnimplementedError();
  }

  @override
  Future<Map<String, List<Media>>> getMangaList() {
    // not needed
    throw UnimplementedError();
  }

  @override
  Future<Media?>? getMedia(int id, {bool mal = true}) {
    // not needed
    throw UnimplementedError();
  }

  @override
  Future<Map<String, List<Media>>> getMediaLists(
      {required bool anime, required int userId, String? sortOrder}) {
    // TODO: implement getMediaLists
    throw UnimplementedError();
  }

  @override
  Future<bool>? getUserData() => _getUserData();

  @override
  Future<Map<String, List<Media>>>? initHomePage() => _initHomePage();

  @override
  Future<Media?>? mediaDetails(Media media) => _mediaDetails(media);

  @override
  Future<SearchResults?> search(
      SearchResults? searchResults) async {
    // not needed
    throw UnimplementedError();
  }
}
