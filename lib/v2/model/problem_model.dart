import 'package:json_annotation/json_annotation.dart';

import "../util.dart";

part "problem_model.g.dart";

typedef ProblemId = String;

enum ProblemType { typeIdiom, typePoem }

enum ProblemDifficulty { difficultyEasy, difficultyHard }

class Character {
  String? pinyin;
  String char;

  bool isSameChar(Character other) {
    return char == other.char;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character &&
          runtimeType == other.runtimeType &&
          pinyin == other.pinyin &&
          char == other.char;

  @override
  int get hashCode => pinyin.hashCode ^ char.hashCode;

  Character({
    this.pinyin,
    required this.char,
  });
}

@JsonSerializable()
class ProblemModel {
  final ProblemId hash;
  final String word;
  final String pinyin;
  final String explanation;
  final String derivation;
  final String type;
  final String difficulty;

  ProblemModel(this.hash, this.word, this.pinyin, this.explanation,
      this.derivation, this.type, this.difficulty);

  int get length {
    return word.length;
  }

  ProblemType get typeEnum {
    if (type == "idiom") {
      return ProblemType.typeIdiom;
    } else if (type == "poem") {
      return ProblemType.typePoem;
    } else {
      throw Exception("unknown problem type $type");
    }
  }

  ProblemDifficulty get difficultyEnum {
    if (difficulty == "easy") {
      return ProblemDifficulty.difficultyEasy;
    } else if (difficulty == "hard") {
      return ProblemDifficulty.difficultyHard;
    } else {
      throw Exception("unknown problem difficulty $difficulty");
    }
  }

  List<Character> get chars {
    List<Character> ret = [];

    var words = word.split("");
    var pinyins = pinyin.split(" ");

    for (var i = 0; i < word.length; i++) {
      ret.add(Character(pinyin: pinyins.getOrDefault(i, ""), char: words[i]));
    }

    return ret;
  }

  factory ProblemModel.fromJson(Map<String, dynamic> json) =>
      _$ProblemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemModel &&
          runtimeType == other.runtimeType &&
          hash == other.hash &&
          word == other.word &&
          pinyin == other.pinyin &&
          explanation == other.explanation &&
          derivation == other.derivation &&
          type == other.type &&
          difficulty == other.difficulty;

  @override
  int get hashCode =>
      hash.hashCode ^
      word.hashCode ^
      pinyin.hashCode ^
      explanation.hashCode ^
      derivation.hashCode ^
      type.hashCode ^
      difficulty.hashCode;
}
