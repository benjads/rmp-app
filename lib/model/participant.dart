import 'package:crossfire/crossfire.dart';
import 'package:rmp_app/util.dart';

class Participant {
  static const String DEVICE_ID = "device_id";
  static const String STAGE_COMPLETE = "stage_complete";
  static const String PERCENT_CORRECT = "percent_correct";
  static const String SUBMIT_TIME = "submit_time";
  static const String CONDITION = "condition";
  static const String SURVEY = "survey";

  final String deviceId;
  bool stageComplete;
  double percentCorrect;
  num submitTime;
  final Condition condition;
  final Map<String, dynamic> survey;
  FirebaseDocumentReference reference;

  Participant._internal(this.deviceId, this.stageComplete, this.percentCorrect,
      this.submitTime, this.condition, this.survey);

  Participant.fromSnapshot(FirebaseDocument snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.ref);

  Participant.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[DEVICE_ID] != null),
        assert(map[STAGE_COMPLETE] != null),
        assert(map[PERCENT_CORRECT] != null),
        assert(map[SUBMIT_TIME] != null),
        assert(map[CONDITION] != null),
        assert(map[SURVEY] != null),
        deviceId = map[DEVICE_ID],
        stageComplete = map[STAGE_COMPLETE],
        percentCorrect = double.parse(map[PERCENT_CORRECT].toString()),
        submitTime = map[SUBMIT_TIME],
        condition = Condition.values
            .firstWhere((state) => (state.toString() == map[CONDITION])),
        survey = RMPUtil.toMap(map[SURVEY]);

  factory Participant.initialize(String deviceId, Condition condition) {
    return Participant._internal(deviceId, false, -1.0, -1, condition, {});
  }

  Map<String, dynamic> get map {
    return {
      DEVICE_ID: deviceId,
      STAGE_COMPLETE: stageComplete,
      PERCENT_CORRECT: percentCorrect,
      SUBMIT_TIME: submitTime,
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
