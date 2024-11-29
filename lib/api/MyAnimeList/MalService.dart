import 'package:dantotsu/Services/Screens/BaseAnimeScreen.dart';
import 'package:dantotsu/Services/Screens/BaseHomeScreen.dart';
import 'package:dantotsu/Services/Screens/BaseMangaScreen.dart';
import 'package:dantotsu/api/MyAnimeList/Mal.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../Services/BaseServiceData.dart';
import '../../Services/MediaService.dart';
import '../../Services/Screens/BaseLoginScreen.dart';
import 'Screen/MalAnimeScreen.dart';
import 'Screen/MalHomeScreen.dart';
import 'Screen/MalMangaScreen.dart';

class MalService extends MediaService {
  MalService() {
    Mal.getSavedToken();
  }

  @override
  String get iconPath => "assets/svg/mal.svg";

  @override
  BaseServiceData get data => Mal;

  @override
  BaseAnimeScreen? get animeScreen => Get.put(MalAnimeScreen(Mal));

  @override
  BaseHomeScreen? get homeScreen => Get.put(MalHomeScreen(Mal));

  @override
  BaseMangaScreen? get mangaScreen => Get.put(MalMangaScreen(Mal));

  @override
  BaseLoginScreen get loginScreen => Get.put(MalLoginScreen(Mal));
}
class MalLoginScreen extends BaseLoginScreen {
  final MalController Mal;

  MalLoginScreen(this.Mal);
  @override
  void login(BuildContext context) => Mal.login(context);
}