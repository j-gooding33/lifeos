import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/features/quick_add/presentation/quick_add_sheet.dart';

/// The persistent five-item bottom bar, Quick Add included as a plain
/// centre item rather than an elevated floating `+` circle (§3.1) — see
/// DECISIONS.md. Hides on scroll-down, reappears on scroll-up.
///
/// Interpretation note: §3.1's ASCII mockup shows only four text labels
/// ("Home Plans (+) Library Stats") with no "Tasks" label, but the prose
/// two lines later names all five tabs including Tasks with no exception.
/// Hiding a whole navigational destination behind an icon-only nub next to
/// Add seemed like a usability regression the prose doesn't actually ask
/// for, so this renders five equal, fully-labelled items, Add sitting at
/// the boundary between Plans and Tasks per the design note.
class ShellScaffold extends StatefulWidget {
  const ShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  bool _barVisible = true;
  GoRouter? _router;

  // Split either side of the centre Add item rather than indexed into one
  // flat list — Add gets its own equal-width slot in the row (see
  // _buildBar), so it never shares horizontal space with a tab's label no
  // matter how many tabs end up on either side.
  static const _leftTabs = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    (icon: Icons.repeat_outlined, selectedIcon: Icons.repeat, label: 'Plans'),
  ];
  // Stats isn't built yet (§22's placeholder) — left off the bar until it
  // is, per the same "nothing fake" rule as everywhere else, but its
  // StatefulShellBranch in router.dart is untouched so `Routes.stats` still
  // resolves for a deep link or a direct `context.push`.
  static const _rightTabs = [
    (icon: Icons.check_circle_outline, selectedIcon: Icons.check_circle, label: 'Tasks'),
    (icon: Icons.video_library_outlined, selectedIcon: Icons.video_library, label: 'Library'),
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

  // A scroll-hide on one screen must not stay hidden after navigating
  // somewhere else — found live-testing: scroll down a form, submit it,
  // land on a short screen with nothing to scroll, and the bar was gone
  // with no way to bring it back short of finding something to scroll up
  // on. `routerDelegate` (a `Listenable`) fires on every push/pop/goBranch,
  // so this resets visibility on any navigation at all, not just the
  // specific cases this bug happened to be found through.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (!identical(router, _router)) {
      _router?.routerDelegate.removeListener(_showBar);
      _router = router;
      router.routerDelegate.addListener(_showBar);
    }
  }

  void _showBar() {
    if (!_barVisible) setState(() => _barVisible = true);
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_showBar);
    super.dispose();
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
                child: _buildBar(context, barHeight),
              ),
            ),
          ],
        ),
      ),
    );
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
              Expanded(child: _buildAddItem(context)),
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

  Widget _buildAddItem(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: 'Quick add',
      child: InkWell(
        onTap: () => QuickAddSheet.show(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: colors.neutrals.ink2, size: 24),
            const SizedBox(height: 2),
            Text('Add', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
            const SizedBox(height: 4),
            const SizedBox(width: 16, height: 3),
          ],
        ),
      ),
    );
  }
}
