import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

class LMenuItem {
  const LMenuItem({required this.label, required this.onTap, this.icon, this.destructive = false});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool destructive;
}

/// A long-press contextual menu (§2.7) — the accessible equivalent every
/// swipe action needs (§2.9).
class LMenu {
  const LMenu._();

  static Future<void> showAt({
    required BuildContext context,
    required Offset position,
    required List<LMenuItem> items,
  }) async {
    final colors = context.colors;
    final selected = await showMenu<LMenuItem>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      color: colors.neutrals.surface,
      items: [
        for (final item in items)
          PopupMenuItem<LMenuItem>(
            value: item,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 18,
                    color: item.destructive ? colors.semantic('danger').base : colors.neutrals.ink,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  item.label,
                  style: context.textStyles.body.copyWith(
                    color: item.destructive ? colors.semantic('danger').base : colors.neutrals.ink,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    selected?.onTap();
  }
}
