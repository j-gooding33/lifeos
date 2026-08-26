import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/motion.dart';

class LSwipeAction {
  const LSwipeAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
}

/// A list row with swipe-to-reveal actions (§2.7). Every action here is
/// also reachable through the long-press menu this widget shows itself —
/// swipe actions must always have a long-press equivalent (§2.9), so that
/// equivalence is enforced structurally rather than left to callers to
/// remember.
class LSwipeRow extends StatefulWidget {
  const LSwipeRow({
    required this.child,
    this.actions = const [],
    super.key,
  });

  final Widget child;
  final List<LSwipeAction> actions;

  @override
  State<LSwipeRow> createState() => _LSwipeRowState();
}

class _LSwipeRowState extends State<LSwipeRow> {
  double _dragExtent = 0;
  static const _actionWidth = 72.0;

  double get _maxExtent => widget.actions.length * _actionWidth;

  void _showActionsMenu() {
    if (widget.actions.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final action in widget.actions)
                ListTile(
                  leading: Icon(action.icon, color: action.color),
                  title: Text(action.label),
                  onTap: () {
                    Navigator.of(context).pop();
                    action.onTap();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onLongPress: _showActionsMenu,
      onHorizontalDragUpdate: widget.actions.isEmpty
          ? null
          : (details) {
              setState(() {
                _dragExtent = (_dragExtent - details.delta.dx).clamp(0, _maxExtent);
              });
            },
      onHorizontalDragEnd: widget.actions.isEmpty
          ? null
          : (details) {
              setState(() {
                _dragExtent = _dragExtent > _maxExtent / 2 ? _maxExtent : 0;
              });
            },
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          if (_dragExtent > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final action in widget.actions)
                  SizedBox(
                    width: _actionWidth,
                    height: double.infinity,
                    child: ColoredBox(
                      color: action.color ?? colors.accent.base,
                      child: InkWell(
                        onTap: action.onTap,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(action.icon, color: Colors.white),
                            Text(
                              action.label,
                              style: context.textStyles.caption.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          AnimatedContainer(
            duration: LifeMotion.standard,
            curve: LifeMotion.standardCurve,
            transform: Matrix4.translationValues(-_dragExtent, 0, 0),
            color: colors.neutrals.surface,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
