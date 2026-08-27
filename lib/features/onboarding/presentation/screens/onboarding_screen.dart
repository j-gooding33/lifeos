import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/onboarding_answer.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_progress_bar.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/motion.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/onboarding/application/onboarding_providers.dart';

class _QuestionSpec {
  const _QuestionSpec({required this.question, required this.title, required this.chips, this.isMedia = false});
  final OnboardingQuestion question;
  final String title;
  final List<String> chips;
  final bool isMedia;
}

const _questions = [
  _QuestionSpec(
    question: OnboardingQuestion.startDoing,
    title: 'What do you want to start doing?',
    chips: ['Exercise more', 'Drink more water', 'Read every day', 'Save money', 'Learn a language'],
  ),
  _QuestionSpec(
    question: OnboardingQuestion.dailyWeekly,
    title: 'What do you want to do daily or weekly?',
    chips: ['Morning workout', 'Weekly meal prep', 'Journal', 'Call family', 'Tidy up'],
  ),
  _QuestionSpec(
    question: OnboardingQuestion.currentlyWorking,
    title: 'What are you currently working on?',
    chips: ['A work project', 'Home renovation', 'A creative project', 'Job hunting'],
  ),
  _QuestionSpec(
    question: OnboardingQuestion.readWatch,
    title: 'What do you want to read or watch?',
    chips: ['Something on my list', 'A recommendation', "A classic I've missed"],
    isMedia: true,
  ),
];

/// First-run flow (item 8) — one question per screen, free text plus
/// quick-pick chips, a progress bar, swipe or Next/Back to move between
/// them. "Finish" hands every non-empty answer to the rules-based mapper
/// (`onboarding_mapper.dart`) and marks onboarding done; also reachable
/// from Settings ("Redo setup") after the first run.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _controllers = List.generate(_questions.length, (_) => TextEditingController());
  final _selectedChips = List.generate(_questions.length, (_) => <String>{});
  var _page = 0;
  var _mediaType = MediaType.book;
  var _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<OnboardingAnswer> _collectAnswers() {
    final answers = <OnboardingAnswer>[];
    for (var i = 0; i < _questions.length; i++) {
      final spec = _questions[i];
      final mediaType = spec.isMedia ? _mediaType : null;
      final freeText = _controllers[i].text.trim();
      if (freeText.isNotEmpty) {
        answers.add(OnboardingAnswer(question: spec.question, text: freeText, mediaType: mediaType));
      }
      for (final chip in _selectedChips[i]) {
        answers.add(OnboardingAnswer(question: spec.question, text: chip, mediaType: mediaType));
      }
    }
    return answers;
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    await completeOnboarding(ref, _collectAnswers());
    // First run: LifeOsApp swaps to the router itself once hasOnboarded
    // flips, nothing to pop. Reached via Settings' "Redo setup" instead:
    // this pops back to where they came from.
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  void _goNext() {
    if (_page == _questions.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(duration: LifeMotion.standard, curve: LifeMotion.standardCurve);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(LifeSpace.s20),
              child: LProgressBar(
                value: (_page + 1) / _questions.length,
                semanticLabel: 'Step ${_page + 1} of ${_questions.length}',
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _page = index),
                children: [for (var i = 0; i < _questions.length; i++) _buildQuestionPage(context, i)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LifeSpace.s20),
              child: Row(
                children: [
                  if (_page > 0) ...[
                    Expanded(
                      child: LButton(
                        label: 'Back',
                        variant: LButtonVariant.plain,
                        onPressed: () =>
                            _pageController.previousPage(duration: LifeMotion.standard, curve: LifeMotion.standardCurve),
                      ),
                    ),
                    const SizedBox(width: LifeSpace.s12),
                  ],
                  Expanded(
                    child: LButton(
                      label: _page == _questions.length - 1 ? 'Finish' : 'Next',
                      onPressed: _saving ? null : _goNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(BuildContext context, int index) {
    final colors = context.colors;
    final spec = _questions[index];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: LifeSpace.s24),
          Text(spec.title, style: context.textStyles.title2.copyWith(color: colors.neutrals.ink)),
          const SizedBox(height: LifeSpace.s24),
          if (spec.isMedia) ...[
            LSegmented<MediaType>(
              segments: const {MediaType.book: 'Book', MediaType.film: 'Film / show'},
              selected: _mediaType,
              onChanged: (value) => setState(() => _mediaType = value),
            ),
            const SizedBox(height: LifeSpace.s16),
          ],
          LTextField(controller: _controllers[index], placeholder: 'Type your own...'),
          const SizedBox(height: LifeSpace.s16),
          Wrap(
            spacing: LifeSpace.s8,
            runSpacing: LifeSpace.s8,
            children: [
              for (final chip in spec.chips)
                LChip(
                  label: chip,
                  selected: _selectedChips[index].contains(chip),
                  onTap: () => setState(() {
                    if (!_selectedChips[index].remove(chip)) _selectedChips[index].add(chip);
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
