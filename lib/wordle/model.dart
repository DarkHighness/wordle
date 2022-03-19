import 'package:json_annotation/json_annotation.dart';

part "model.g.dart";

@JsonSerializable()
class Idiom {
  final String hash;
  final String word;
  final String pinyin;
  final String explanation;
  final String derivation;
  final String type;

  Idiom(this.hash, this.word, this.pinyin, this.explanation, this.derivation,
      this.type);

  factory Idiom.fromJson(Map<String, dynamic> json) => _$IdiomFromJson(json);

  Map<String, dynamic> toJson() => _$IdiomToJson(this);
}

class Character {
  final String word;
  final String pinyin;

  Character(this.word, this.pinyin);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          pinyin == other.pinyin;

  @override
  int get hashCode => word.hashCode ^ pinyin.hashCode;
}

class Problem {
  final Idiom idiom;

  // 储存备选字
  // Tips: 由于生成的时候, 备选字重新组合后可能出现原本不在原始范围内的词语, 因此, 直接去db中检索
  final List<Character> potentialItems;

  Problem(this.idiom, this.potentialItems);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Problem &&
          runtimeType == other.runtimeType &&
          idiom == other.idiom &&
          potentialItems == other.potentialItems;

  @override
  int get hashCode => idiom.hashCode ^ potentialItems.hashCode;
}

@JsonSerializable()
class UserData {
  late List<String> solved;
  late int totalTries;
  late bool hardMode;

  UserData(this.solved, this.totalTries, this.hardMode);

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
