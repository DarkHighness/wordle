import 'dart:convert';

import 'package:flutter/services.dart';

import 'db.dart';
import 'model.dart';

Future<IdiomDb> readAssetsIdiom() async {
  final String idiomsJson = await rootBundle.loadString("assets/idioms.json");
  final List<Idiom> idiomList =
      List<Idiom>.from(jsonDecode(idiomsJson).map((e) => Idiom.fromJson(e)));

  return IdiomDb(idiomList);
}

Future<void> saveUserData() async {}

Future<UserData> loadUserData() async {
  return UserData([]);
}
