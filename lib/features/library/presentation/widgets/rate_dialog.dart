import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_star_rating.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';

/// A quick, standalone rating picker — Part 3's "★ Rate" action, and Part
/// 21's "the rating is optional... change it later" without needing to
/// touch watched/finished status at all (§43: rating before watching is
/// allowed).
class RateDialog {
  const RateDialog._();

  static Future<void> show(BuildContext context, WidgetRef ref, AppLibraryItem item) async {
    var rating = item.rating ?? 0.0;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final colors = context.colors;
          return AlertDialog(
            title: Text(item.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LStarRating(rating: rating, size: 32, onChanged: (v) => setState(() => rating = v)),
                const SizedBox(height: LifeSpace.s8),
                Text(
                  rating == 0 ? 'Tap a star to rate' : rating.toString(),
                  style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              LButton(
                label: 'Save',
                onPressed: () {
                  ref.read(libraryItemRepositoryProvider).setRating(item.id, rating == 0 ? null : rating);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
