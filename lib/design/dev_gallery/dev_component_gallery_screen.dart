import 'package:flutter/material.dart';
import 'package:life_os/design/components/l_avatar.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_day_rail.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_heatmap_grid.dart';
import 'package:life_os/design/components/l_icon_button.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_progress_bar.dart';
import 'package:life_os/design/components/l_progress_ring.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_stat.dart';
import 'package:life_os/design/components/l_swipe_row.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_time_picker.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// Debug-only screen for browsing every §2.7 component live (M2 DoD).
/// Never linked from a production route — see how it's reached from
/// `app.dart`, gated on `kDebugMode`.
class DevComponentGalleryScreen extends StatefulWidget {
  const DevComponentGalleryScreen({super.key});

  @override
  State<DevComponentGalleryScreen> createState() => _DevComponentGalleryScreenState();
}

class _DevComponentGalleryScreenState extends State<DevComponentGalleryScreen> {
  bool _checked = true;
  int _segment = 0;
  final double _sliderStandIn = 0.6;
  DateTime? _date = DateTime(2026, 9, 2);
  TimeOfDay? _time = const TimeOfDay(hour: 18, minute: 30);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Component gallery (debug)')),
      backgroundColor: colors.neutrals.bg,
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s20),
        children: [
          _section('LCard', const LCard(child: Text('Card content'))),
          _section('LSectionHeader', const LSectionHeader(title: 'Plans today')),
          _section(
            'LListTile',
            const LListTile(title: 'Finish geography project', subtitle: 'Due today'),
          ),
          _section(
            'LCheckCircle',
            LCheckCircle(checked: _checked, onChanged: (v) => setState(() => _checked = v)),
          ),
          _section(
            'LSwipeRow',
            LSwipeRow(
              actions: [LSwipeAction(label: 'Delete', icon: Icons.delete, onTap: () {})],
              child: const LListTile(title: 'Swipe or long-press me'),
            ),
          ),
          _section('LChip', const LChip(label: 'Films', selected: true)),
          _section(
            'LSegmented',
            LSegmented<int>(
              segments: const {0: 'Today', 1: 'Upcoming'},
              selected: _segment,
              onChanged: (v) => setState(() => _segment = v),
            ),
          ),
          _section(
            'LButton',
            Wrap(
              spacing: LifeSpace.s8,
              children: [
                LButton(label: 'Filled', onPressed: () {}),
                LButton(label: 'Tonal', onPressed: () {}, variant: LButtonVariant.tonal),
                LButton(label: 'Plain', onPressed: () {}, variant: LButtonVariant.plain),
                LButton(
                  label: 'Destructive',
                  onPressed: () {},
                  variant: LButtonVariant.destructive,
                ),
              ],
            ),
          ),
          _section(
            'LIconButton',
            LIconButton(icon: Icons.add, onPressed: () {}, semanticLabel: 'Add'),
          ),
          _section('LTextField', const LTextField(placeholder: 'Add a task')),
          _section(
            'LDatePicker',
            LDatePicker(date: _date, onChanged: (v) => setState(() => _date = v)),
          ),
          _section(
            'LTimePicker',
            LTimePicker(time: _time, onChanged: (v) => setState(() => _time = v)),
          ),
          _section('LProgressBar', LProgressBar(value: _sliderStandIn)),
          _section('LProgressRing', LProgressRing(value: _sliderStandIn)),
          _section('LStat', const LStat(value: '47', caption: 'done')),
          _section(
            'LHeatmapGrid',
            LHeatmapGrid(values: List.generate(28, (i) => i % 5 == 0 ? null : (i % 4) / 3)),
          ),
          _section(
            'LEmptyState',
            SizedBox(
              height: 220,
              child: LEmptyState(
                icon: Icons.inbox_outlined,
                title: 'Nothing here yet',
                message: 'Add your first task to get started.',
                actionLabel: 'Add task',
                onAction: () {},
              ),
            ),
          ),
          _section(
            'LErrorState',
            SizedBox(
              height: 220,
              child: LErrorState(message: "Couldn't load your tasks.", onRetry: () {}),
            ),
          ),
          _section('LLoadingShimmer', const LLoadingShimmer(width: 200)),
          _section('LAvatar', const LAvatar(name: 'Sam Rivera')),
          _section('LPosterTile', const LPosterTile(width: 90)),
          _section(
            'LDayRail',
            const LDayRail(itemFractions: [0.1, 0.4, 0.8], progressFraction: 0.5, height: 120),
          ),
          _section(
            'LSheet',
            LButton(
              label: 'Open sheet',
              onPressed: () => LSheet.show<void>(
                context: context,
                snapPoints: const [0.4],
                builder: (context) =>
                    const Padding(padding: EdgeInsets.all(16), child: Text('Sheet content')),
              ),
            ),
          ),
          _section(
            'LMenu',
            Builder(
              builder: (context) => LButton(
                label: 'Open menu',
                onPressed: () => LMenu.showAt(
                  context: context,
                  position: const Offset(200, 200),
                  items: [LMenuItem(label: 'Edit', icon: Icons.edit, onTap: () {})],
                ),
              ),
            ),
          ),
          _section(
            'LToast',
            Builder(
              builder: (context) => LButton(
                label: 'Show toast',
                onPressed: () => LToast.show(context, 'Moved to tomorrow'),
              ),
            ),
          ),
          _section(
            'LConfirmDialog',
            Builder(
              builder: (context) => LButton(
                label: 'Delete',
                variant: LButtonVariant.destructive,
                onPressed: () => LConfirmDialog.show(
                  context,
                  title: 'Delete this task?',
                  message: 'This cannot be undone.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: LifeSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textStyles.mono.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s8),
          child,
        ],
      ),
    );
  }
}
