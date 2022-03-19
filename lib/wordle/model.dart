import 'package:json_annotation/json_annotation.dart';

part "model.g.dart";

@JsonSerializable()
class Idiom {
  final String hash;
  final String word;
  final String pinyin;
  final String explanation;
  final String derivation;

  Idiom(this.hash, this.word, this.pinyin, this.explanation, this.derivation);

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
}

@JsonSerializable()
class IdiomLog {
  final List<String> log;

  IdiomLog(this.log) {
    assert(log.length == 4);
  }

  factory IdiomLog.fromJson(Map<String, dynamic> json) =>
      _$IdiomLogFromJson(json);

  Map<String, dynamic> toJson() => _$IdiomLogToJson(this);
}

@JsonSerializable()
class IdiomStatus {
  final String hash;
  late List<IdiomLog> logs;

  IdiomStatus(this.hash, this.logs);

  factory IdiomStatus.fromJson(Map<String, dynamic> json) =>
      _$IdiomStatusFromJson(json);

  Map<String, dynamic> toJson() => _$IdiomStatusToJson(this);
}

@JsonSerializable()
class UserData {
  late List<IdiomStatus> status;

  UserData(this.status);

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
