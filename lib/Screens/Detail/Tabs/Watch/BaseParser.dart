
import 'package:flutter/cupertino.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../DataClass/Media.dart';
import '../../../../Preferences/IsarDataClasses/Selected/Selected.dart';
import '../../../../Preferences/IsarDataClasses/ShowResponse/ShowResponse.dart';
import '../../../../Preferences/PrefManager.dart';
import '../../../../Services/ServiceSwitcher.dart';
import '../../../../Widgets/CustomBottomDialog.dart';
import '../../../../api/Mangayomi/Eval/dart/model/m_manga.dart';
import '../../../../api/Mangayomi/Model/Source.dart';
import '../../../../api/Mangayomi/Search/search.dart';
import 'Widgets/WrongTitle.dart';

abstract class BaseParser extends GetxController {
  var selectedMedia = Rxn<MManga?>(null);
  var status = Rxn<String>(null);
  var source = Rxn<Source>(null);
  var errorType = Rxn<ErrorType>(ErrorType.None);

  void saveSelected(int id, Selected data) {
    var sourceName = Provider.of<MediaServiceProvider>(Get.context!,listen: false).currentService.getName;
    PrefManager.setCustomVal("Selected-$id-$sourceName", data);
  }

  Selected loadSelected(Media mediaData) {
    var sourceName = Provider.of<MediaServiceProvider>(Get.context!,listen: false).currentService.getName;
    return PrefManager.getCustomVal("Selected-${mediaData.id}-$sourceName") ?? Selected();
  }

  Future<void> searchMedia(Source source, Media mediaData,
      {Function(MManga? response)? onFinish}) async {
    selectedMedia.value = null;
    var saved = _loadShowResponse(source, mediaData);
    if (saved != null) {
      var response = MManga(
        name: saved.name,
        imageUrl: saved.coverUrl,
        link: saved.link,
      );
      selectedMedia.value = response;
      _saveShowResponse(mediaData, response, source, selected: true);
      onFinish?.call(response);
      return;
    }
    MManga? response;
    status.value = "Searching : ${mediaData.mainName()}";
    final mediaFuture = search(
      source: source,
      page: 1,
      query: mediaData.mainName(),
      filterList: [],
    );

    final media = await mediaFuture;

    List<MManga> sortedResults = media!.list.isNotEmpty
        ? (media.list
          ..sort((a, b) {
            final aRatio = ratio(
                a.name!.toLowerCase(), mediaData.mainName().toLowerCase());
            final bRatio = ratio(
                b.name!.toLowerCase(), mediaData.mainName().toLowerCase());
            return bRatio.compareTo(aRatio);
          }))
        : [];
    sortedResults.firstOrNull;
    response = sortedResults.firstOrNull;

    if (response == null ||
        ratio(response.name!.toLowerCase(),
                mediaData.mainName().toLowerCase()) <
            100) {
      status.value = "Searching : ${mediaData.nameRomaji}";
      final mediaFuture = search(
        source: source,
        page: 1,
        query: mediaData.nameRomaji,
        filterList: [],
      );
      final media = await mediaFuture;
      List<MManga> sortedRomajiResults = media!.list.isNotEmpty
          ? (media.list
            ..sort((a, b) {
              final aRatio = ratio(
                  a.name!.toLowerCase(), mediaData.nameRomaji.toLowerCase());
              final bRatio = ratio(
                  b.name!.toLowerCase(), mediaData.nameRomaji.toLowerCase());
              return bRatio.compareTo(aRatio);
            }))
          : [];
      var closestRomaji = sortedRomajiResults.firstOrNull;
      if (response == null) {
        response = closestRomaji;
      } else {
        var romajiRatio = ratio(closestRomaji?.name?.toLowerCase() ?? '',
            mediaData.nameRomaji.toLowerCase());
        var mainNameRatio = ratio(
            response.name!.toLowerCase(), mediaData.mainName().toLowerCase());
        if (romajiRatio > mainNameRatio) {
          response = closestRomaji;
        }
      }
    }
    if (response == null) {
      for (var synonym in mediaData.synonyms) {
        if (_isEnglish(synonym)) {
          status.value = "Searching : $synonym";
          final mediaFuture = search(
            source: source,
            page: 1,
            query: synonym,
            filterList: [],
          );
          final media = await mediaFuture;
          List<MManga> sortedResults = media!.list.isNotEmpty
              ? (media.list
                ..sort((a, b) {
                  final aRatio =
                      ratio(a.name!.toLowerCase(), synonym.toLowerCase());
                  final bRatio =
                      ratio(b.name!.toLowerCase(), synonym.toLowerCase());
                  return bRatio.compareTo(aRatio);
                }))
              : [];
          var closest = sortedResults.firstOrNull;
          if (closest != null) {
            if (ratio(closest.name!.toLowerCase(), synonym.toLowerCase()) >
                90) {
              response = closest;
              break;
            }
          }
        }
      }
    }
    if (response != null) {
      _saveShowResponse(mediaData, response, source);
      selectedMedia.value = response;
      onFinish?.call(response);
    } else {
      status.value = "Nothing Found";
      onFinish?.call(response);
    }
  }

  bool _isEnglish(String name) {
    final englishRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
    return englishRegex.hasMatch(name);
  }

  ShowResponse? _loadShowResponse(Source source, Media mediaData) {
    return PrefManager.getCustomVal<ShowResponse?>(
        "${source.name}_${mediaData.id}_source");
  }

  _saveShowResponse(Media mediaData, MManga response, Source source,
      {bool selected = false}) {
    status.value =
        selected ? "Selected : ${response.name}" : "Found : ${response.name}";
    var show = ShowResponse(
        name: response.name!,
        link: response.link!,
        coverUrl: response.imageUrl!);
    PrefManager.setCustomVal<ShowResponse>(
        "${source.name}_${mediaData.id}_source", show);
  }

  Future<void> wrongTitle(
    BuildContext context,
    Media mediaData,
    Function(MManga)? onChange,
  ) async {
    var dialog = WrongTitleDialog(
        source: source.value!,
        mediaData: mediaData,
        selectedMedia: selectedMedia,
        onChanged: (m) {
          selectedMedia.value = m;
          _saveShowResponse(mediaData, m, source.value!, selected: true);
          onChange?.call(m);
        });
    showCustomBottomDialog(context, dialog);
  }
}

enum ErrorType{
  None,
  NotFound,
  NoResult
}