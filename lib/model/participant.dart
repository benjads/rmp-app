import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmp_app/util.dart';

class Participant {
  static const String DEVICE_ID = "device_id";
  static const String STAGE_COMPLETE = "stage_complete";
  static const String PERCENT_CORRECT = "percent_correct";
  static const String CONDITION = "condition";
  static const String SURVEY = "survey";

  final String deviceId;
  bool stageComplete;
  final double percentCorrect;
  final Condition condition;
  Map<String, dynamic> survey;
  DocumentReference reference;

  Participant._internal(this.deviceId, this.stageComplete, this.percentCorrect,
      this.condition, this.survey);

  Participant.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Participant.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[DEVICE_ID] != null),
        assert(map[STAGE_COMPLETE] != null),
        assert(map[PERCENT_CORRECT] != null),
        assert(map[CONDITION] != null),
        assert(map[SURVEY] != null),
        deviceId = map[DEVICE_ID],
        stageComplete = map[STAGE_COMPLETE],
        percentCorrect = map[PERCENT_CORRECT],
        condition = Condition.values
            .firstWhere((state) => (state.toString() == map[CONDITION])),
        survey = RMPUtil.toMap(map[SURVEY]);

  factory Participant.initialize(String deviceId, Condition condition) {
    return Participant._internal(deviceId, false, -1.0, condition, {});
  }

  Map<String, dynamic> get map {
    return {
      DEVICE_ID: deviceId,
      STAGE_COMPLETE: stageComplete,
      PERCENT_CORRECT: percentCorrect,
      CONDITION: condition.toString(),
      SURVEY: survey
    };
  }
}

enum Condition { BASELINE, MNEMONIC }

enum SurveyQuestion { ENGLISH_READING, ENGLISH_WRITING }

extension SurveyExtension on SurveyQuestion {
  String get questionText {
    switch (this) {
      case SurveyQuestion.ENGLISH_READING:
        return "Please rate your English reading proficiency";
      case SurveyQuestion.ENGLISH_WRITING:
        return "Please rate your English writing proficiency";
      default:
        return null;
    }
  }

  List<String> get radioOptions {
    switch (this) {
      case SurveyQuestion.ENGLISH_READING:
      case SurveyQuestion.ENGLISH_WRITING:
        return ["Proficient", "Fluent", "Native Speaker"];
      default:
        return null;
    }
  }
}
