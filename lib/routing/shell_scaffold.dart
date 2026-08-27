import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/quick_add/presentation/quick_add_sheet.dart';

/// The persistent five-tab bottom bar plus the floating `+` action (§3.1).
///
/// Interpretation note: §3.1's ASCII mockup shows only four text labels
/// ("Home Plans (+) Library Stats") with no "Tasks" label, but the prose
/// two lines later names all five tabs including Tasks with no exception.
/// Hiding a whole navigational destination behind an icon-only nub next to
/// the FAB seemed like a usability regression the prose doesn't actually
/// ask for, so this renders five equal, fully-labelled tabs and floats the
/// FAB above the boundary between Plans and Tasks, per the design note.
/// See DECISIONS.md.
class ShellScaffold extends StatefulWidget {
  const ShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  bool _barVisible = true;

  // Split either side of the FAB rather than indexed into one flat list —
  // the FAB gets its own equal-width slot in the row (see _buildBar), so it
  // never shares horizontal space with a tab's label no matter how many
  // tabs end up on either side.
  static const _leftTabs = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    (icon: Icons.repeat_outlined, selectedIcon: Icons.repeat, label: 'Plans'),
  ];
  static const _rightTabs = [
    (icon: Icons.check_circle_outline, selectedIcon: Icons.check_circle, label: 'Tasks'),
    (icon: Icons.video_library_outlined, selectedIcon: Icons.video_library, label: 'Library'),
    (icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: 'Stats'),
  ];
  static const _tabs = [..._leftTabs, ..._rightTabs];

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse && _barVisible) {
      setState(() => _barVisible = false);
    } else if (notification.direction == ScrollDirection.forward && !_barVisible) {
      setState(() => _barVisible = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const barHeight = 64.0;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      body: NotificationListener<UserScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(
          children: [
            Positioned.fill(child: widget.navigationShell),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                curve: const Cubic(0.2, 0, 0, 1),
                offset: _barVisible ? Offset.zero : const Offset(0, 1),
                child: SizedBox(
                  height: barHeight + LifeSpace.s24,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildBar(context, barHeight),
                      Positioned(
                        left: _fabSlotCenterX(context) - 28,
                        bottom: barHeight - 12,
                        child: _buildFab(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The FAB's own equal-width slot sits between `_leftTabs` and
  /// `_rightTabs` as one more `Expanded` share of the row, so its centre is
  /// simple to compute in lockstep with `_buildBar`'s layout: slot index
  /// `_leftTabs.length` out of `_tabs.length + 1` equal shares.
  double _fabSlotCenterX(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final totalSlots = _tabs.length + 1;
    return width * (_leftTabs.length + 0.5) / totalSlots;
  }

  Widget _buildBar(BuildContext context, double height) {
    final colors = context.colors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: colors.neutrals.surface.withValues(alpha: 0.88),
            border: Border(top: BorderSide(color: colors.neutrals.border)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _leftTabs.length; i++) Expanded(child: _buildTabItem(context, i)),
              const Expanded(child: SizedBox.shrink()),
              for (var i = 0; i < _rightTabs.length; i++)
                Expanded(child: _buildTabItem(context, _leftTabs.length + i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index) {
    final colors = context.colors;
    final tab = _tabs[index];
    final selected = index == widget.navigationShell.currentIndex;
    final color = selected ? colors.accent.base : colors.neutrals.ink2;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: () => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? tab.selectedIcon : tab.icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(tab.label, style: context.textStyles.caption.copyWith(color: color)),
            const SizedBox(height: 4),
            SizedBox(
              width: 16,
              height: 3,
              child: selected
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.accent.base,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: 'Quick add',
      child: Material(
        color: colors.accent.base,
        shape: const CircleBorder(),
        elevation: 6,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => QuickAddSheet.show(context),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.add, color: colors.accent.on),
          ),
        ),
      ),
    );
  }
}
