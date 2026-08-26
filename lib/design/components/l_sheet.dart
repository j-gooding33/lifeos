import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// Bottom sheet with named snap points (§2.7, §3.3), e.g. Quick Add's
/// 40%/72%/full. Snap points are fractions of the screen height.
class LSheet {
  const LSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    List<double> snapPoints = const [0.5],
    bool isScrollControlled = true,
  }) {
    final colors = context.colors;
    final sorted = [...snapPoints]..sort();
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: sorted.first,
          minChildSize: sorted.first,
          maxChildSize: sorted.last,
          snap: true,
          snapSizes: sorted,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.neutrals.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(LifeRadius.sheet)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: LifeSpace.s12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.neutrals.border,
                      borderRadius: BorderRadius.circular(LifeRadius.pill),
                    ),
                  ),
                  Expanded(
                    child: ListView(controller: scrollController, children: [builder(context)]),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
