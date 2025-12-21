import 'dart:convert';
import 'dart:io';

import 'package:dartotsu/Functions/Function.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../DataClass/Media.dart';
import '../../Preferences/PrefManager.dart';
import '../../Widgets/CustomBottomDialog.dart';
import 'DiscordService.dart';
import 'Login.dart';
import 'RpcExternalAsset.dart';

const String applicationId = "1163925779692912771";
const String smallImage =
    "https://cdn.discordapp.com/emojis/1305525420938100787.gif?size=48&animated=true&name=dartotsu";
const String smallImageAniList =
    "mp:external/rHOIjjChluqQtGyL_UHk6Z4oAqiVYlo_B7HSGPLSoUg/%3Fsize%3D128/https/cdn.discordapp.com/icons/210521487378087947/a_f54f910e2add364a3da3bb2f2fce0c72.webp";

var Discord = Get.put(_DiscordController());

class _DiscordController extends GetxController {
  var token = "".obs;
  var userName = "".obs;
  var avatar = "".obs;
  var _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    // Load the token but don't set idle RPC immediately
    getSavedToken();
    
    // Use a post-frame callback to ensure the UI is rendered before initializing Discord
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDiscordWithDelay();
    });
  }
  
  void _initializeDiscordWithDelay() {
    // Delay the Discord initialization to avoid blocking the UI
    Future.delayed(const Duration(seconds: 2), () {
      if (token.isNotEmpty && !_isInitialized) {
        _isInitialized = true;
        setIdleRpc();
      }
    });
  }

  bool getSavedToken() {
    token.value = loadData(PrefName.discordToken);
    userName.value = loadData(PrefName.discordUserName);
    avatar.value = loadData(PrefName.discordAvatar);
    return token.isNotEmpty;
  }

  Future<void> saveToken(String newToken) async {
    saveData(PrefName.discordToken, newToken);
    token.value = newToken;
    // Set idle RPC after login with a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setIdleRpc();
    });
  }

  Future<void> removeSavedToken() async {
    token.value = '';
    userName.value = '';
    avatar.value = '';
    _isInitialized = false;
    saveData(PrefName.discordToken, '');
    saveData(PrefName.discordUserName, '');
    saveData(PrefName.discordAvatar, '');
    // Stop RPC on logout
    if (DiscordService.isInitialized) {
      DiscordService.stopRPC();
    }
  }

  void warning(BuildContext context) {
    final dialog = CustomBottomDialog(
      title: "Warning",
      viewList: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            "By logging in, your discord will now show what you are watching & reading on Dartotsu\n\n\n"
            "If you are on invisible mode, logging in will make you online, when you open Dartotsu.\n\n"
            "This does break the Discord TOS. \nAlthough Discord has never banned anyone for using Custom Rich Presence(what Dartotsu uses), You have still been warned.\n\ndartotsu is not responsible for anything that happens to your account.",
          ),
        )
      ],
      negativeText: "Cancel",
      negativeCallback: () {
        Navigator.of(context).pop();
      },
      positiveText: "Login",
      positiveCallback: () {
        Navigator.of(context).pop();
        navigateToPage(
          context,
          Platform.isLinux ? const LinuxLogin() : const MobileLogin(),
        );
      },
    );
    showCustomBottomDialog(context, dialog);
  }

  // Set idle RPC when not watching/reading
  Future<void> setIdleRpc() async {
    if (token.isEmpty) return;

    try {
      var smallIcon = await smallImage.getDiscordUrl();
      
      final Map<String, dynamic> rpc = {
        'op': 3,
        'd': {
          'activities': [
            {
              'application_id': applicationId,
              'name': 'Dartotsu',
              'details': 'Browsing',
              'state': 'Looking for something to watch',
              'type': 3,
              'assets': {
                'large_image': smallIcon,
                'large_text': 'Dartotsu',
                'small_image': smallIcon,
                'small_text': 'Dartotsu',
              },
              'buttons': [
                'Download Dartotsu',
              ],
              'metadata': {
                'button_urls': [
                  'https://github.com/aayush2622/Dartotsu',
                ],
              },
            },
          ],
          'afk': false,
          'since': null,
          'status': 'online',
        },
      };
      
      if (DiscordService.isInitialized) {
        DiscordService.stopRPC();
      }
      DiscordService.setPresence(jsonEncode(rpc));
      debugPrint('Set idle Discord RPC');
    } catch (e) {
      debugPrint('Error setting idle RPC: $e');
    }
  }

  Future<void> setRpc(
    Media mediaData, {
    DEpisode? episode,
    int? eTime,
    int? currentTime,
  }) async {
    if (token.isEmpty) return;

    var isAnime = mediaData.anime != null;
    var totalFromSource = isAnime
        ? mediaData.anime?.episodes?.values.last.episodeNumber
        : mediaData.manga?.chapters?.last.episodeNumber;

    var totalFromMedia = isAnime
        ? mediaData.anime?.totalEpisodes
        : mediaData.manga?.totalChapters;

    var total = (totalFromMedia ?? totalFromSource ?? "??").toString();
    DateTime startTime = DateTime.now();
    DateTime initPosition =
        DateTime.now().subtract(Duration(seconds: currentTime ?? 0));
    DateTime endTime = startTime.add(
      Duration(
        seconds: (eTime?.toInt() ?? 24 * 60 * 60) - (currentTime ?? 0),
      ),
    );
    int startTimestamp = initPosition.millisecondsSinceEpoch;
    int endTimestamp = endTime.millisecondsSinceEpoch;
    var smallIcon = await smallImage.getDiscordUrl();
    try {
      final Map<String, dynamic> rpc = {
        'op': 3,
        'd': {
          'activities': [
            {
              'application_id': applicationId,
              'name': mediaData.userPreferredName,
              'details': episode?.name,
              'state':
                  '${isAnime ? "Episode" : "Chapter"}: ${episode?.episodeNumber}/$total',
              'type': 3,
              "timestamps": {"end": endTimestamp, "start": startTimestamp},
              'assets': {
                'large_image': await (episode?.thumbnail ?? mediaData.cover)
                        ?.getDiscordUrl() ??
                    smallIcon,
                'large_text': mediaData.userPreferredName,
                'small_image': smallIcon,
                'small_text': 'Dartotsu',
              },
              'buttons': [
                'View ${isAnime ? 'Anime' : 'Manga'}',
                '${isAnime ? 'Watch' : 'Read'} on Dartotsu',
              ],
              'metadata': {
                'button_urls': [
                  'https://anilist.co/${isAnime ? 'anime' : 'manga'}/${mediaData.id}',
                  'https://github.com/aayush2622/Dartotsu',
                ],
              },
            },
          ],
          'afk': true,
          'since': null,
          'status': 'idle',
        },
      };
      if (DiscordService.isInitialized) {
        DiscordService.stopRPC();
      }
      DiscordService.setPresence(jsonEncode(rpc));
    } catch (e) {
      debugPrint('Error setting RPC: $e');
    }
  }

  // Call this when user stops watching/reading
  Future<void> clearWatchingRpc() async {
    await setIdleRpc();
  }
}
