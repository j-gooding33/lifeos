import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/routing/routes.dart';

class _Suggestion {
  const _Suggestion(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

/// Shown instead of a plain empty-state illustration when a Home section
/// (Today, Upcoming) genuinely has nothing in it — "Home is never empty".
///
/// These are honest generic starters, not personalised: onboarding (which
/// will supply real "what do you want to start doing" answers) doesn't
/// exist yet. Once it does, swap this widget's fixed [_fallback] list for
/// a provider reading the user's own answers — the tap targets already
/// route to the right creation flow per answer category, so the card
/// itself shouldn't need to change, only where its list comes from.
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({required this.title, super.key});

  final String title;

  static const _fallback = [
    _Suggestion('Add a task for something on your mind', Icons.check_circle_outline, Routes.tasksNew),
    _Suggestion('Set up a daily or weekly habit', Icons.repeat, Routes.plansNew),
    _Suggestion('Start tracking a film or book', Icons.movie_outlined, Routes.libraryFilmsSearch),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LSectionHeader(title: title),
          const SizedBox(height: LifeSpace.s12),
          for (final suggestion in _fallback) ...[
            InkWell(
              onTap: () => context.push(suggestion.route),
              borderRadius: BorderRadius.circular(LifeRadius.control),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
                child: Row(
                  children: [
                    Icon(suggestion.icon, size: 18, color: colors.accent.base),
                    const SizedBox(width: LifeSpace.s12),
                    Expanded(
                      child: Text(
                        suggestion.label,
                        style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: colors.neutrals.ink3),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
