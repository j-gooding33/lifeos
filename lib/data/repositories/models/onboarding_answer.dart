import 'package:life_os/data/media/media_types.dart';

/// The four first-run questions (item 8) — each maps to a different kind
/// of real record once answered; see `OnboardingMapper`.
enum OnboardingQuestion { startDoing, dailyWeekly, currentlyWorking, readWatch }

/// One free-text or quick-pick answer to one [OnboardingQuestion]. A
/// question can have several answers (the user can type free text *and*
/// pick chips) — each becomes its own record.
class OnboardingAnswer {
  const OnboardingAnswer({required this.question, required this.text, this.mediaType});

  factory OnboardingAnswer.fromJson(Map<String, Object?> json) {
    return OnboardingAnswer(
      question: OnboardingQuestion.values.byName(json['question']! as String),
      text: json['text']! as String,
      mediaType: json['mediaType'] == null ? null : MediaType.values.byName(json['mediaType']! as String),
    );
  }

  final OnboardingQuestion question;
  final String text;

  /// Only meaningful for [OnboardingQuestion.readWatch] — which shelf the
  /// answer belongs on. Chosen by the user via the screen's Book/Film
  /// toggle, not guessed from the text (there's no NLP here — see
  /// `OnboardingMapper`).
  final MediaType? mediaType;

  Map<String, Object?> toJson() => {'question': question.name, 'text': text, 'mediaType': mediaType?.name};
}
