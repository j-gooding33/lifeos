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

import 'golden_harness.dart';

void main() {
  goldenMatrix('l_card', () => const LCard(child: Text('Card content')));

  goldenMatrix(
    'l_section_header',
    () => const LSectionHeader(title: 'Plans today'),
  );

  goldenMatrix(
    'l_list_tile',
    () => const LListTile(title: 'Finish geography project', subtitle: 'Due today'),
  );

  goldenMatrix('l_check_circle', () => LCheckCircle(checked: true, onChanged: (_) {}));

  goldenMatrix(
    'l_swipe_row',
    () => LSwipeRow(
      actions: [LSwipeAction(label: 'Delete', icon: Icons.delete, onTap: () {})],
      child: const LListTile(title: 'Swipe me'),
    ),
  );

  goldenMatrix('l_chip', () => const LChip(label: 'Films', selected: true));

  goldenMatrix(
    'l_segmented',
    () => LSegmented<int>(
      segments: const {0: 'Today', 1: 'Upcoming'},
      selected: 0,
      onChanged: (_) {},
    ),
  );

  goldenMatrix(
    'l_button',
    () => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LButton(label: 'Filled', onPressed: () {}),
        LButton(label: 'Tonal', onPressed: () {}, variant: LButtonVariant.tonal),
        LButton(label: 'Plain', onPressed: () {}, variant: LButtonVariant.plain),
        LButton(label: 'Destructive', onPressed: () {}, variant: LButtonVariant.destructive),
      ],
    ),
  );

  goldenMatrix(
    'l_icon_button',
    () => LIconButton(icon: Icons.add, onPressed: () {}, semanticLabel: 'Add'),
  );

  goldenMatrix('l_text_field', () => const LTextField(placeholder: 'Add a task'));

  goldenMatrix('l_date_picker', () => LDatePicker(date: DateTime(2026, 9, 2), onChanged: (_) {}));

  goldenMatrix(
    'l_time_picker',
    () => LTimePicker(time: const TimeOfDay(hour: 18, minute: 30), onChanged: (_) {}),
  );

  goldenMatrix('l_progress_bar', () => const LProgressBar(value: 0.6));

  goldenMatrix(
    'l_progress_ring',
    () => const LProgressRing(value: 0.7, child: Text('70%')),
  );

  goldenMatrix('l_stat', () => const LStat(value: '47', caption: 'done'));

  goldenMatrix(
    'l_heatmap_grid',
    () => LHeatmapGrid(values: List.generate(28, (i) => i % 5 == 0 ? null : (i % 4) / 3)),
  );

  goldenMatrix(
    'l_empty_state',
    () => LEmptyState(
      icon: Icons.inbox_outlined,
      title: 'Nothing here yet',
      message: 'Add your first task to get started.',
      actionLabel: 'Add task',
      onAction: () {},
    ),
  );

  goldenMatrix('l_error_state', () => LErrorState(message: "Couldn't load your tasks.", onRetry: () {}));

  goldenMatrix('l_loading_shimmer', () => const LLoadingShimmer(width: 160));

  goldenMatrix('l_avatar', () => const LAvatar(name: 'Sam Rivera'));

  goldenMatrix('l_poster_tile', () => const LPosterTile(width: 80));

  goldenMatrix(
    'l_day_rail',
    () => const LDayRail(itemFractions: [0.1, 0.4, 0.8], progressFraction: 0.5, height: 120),
  );

  // The remaining four are action/overlay helpers. Their content renders
  // into the root Overlay, outside the trigger's RepaintBoundary, so these
  // golden the whole screen after tapping the trigger rather than reusing
  // `goldenMatrix` (which only ever captures the trigger itself).
  goldenOverlayMatrix(
    'l_sheet',
    triggerLabel: 'Open',
    builder: () => Builder(
      builder: (context) {
        return LButton(
          label: 'Open',
          onPressed: () => LSheet.show<void>(
            context: context,
            snapPoints: const [0.4],
            builder: (context) => const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sheet content'),
            ),
          ),
        );
      },
    ),
  );

  goldenOverlayMatrix(
    'l_menu',
    triggerLabel: 'Open menu',
    builder: () => Builder(
      builder: (context) {
        return LButton(
          label: 'Open menu',
          onPressed: () => LMenu.showAt(
            context: context,
            position: const Offset(100, 100),
            items: [LMenuItem(label: 'Edit', icon: Icons.edit, onTap: () {})],
          ),
        );
      },
    ),
  );

  goldenOverlayMatrix(
    'l_toast',
    triggerLabel: 'Show toast',
    builder: () => Builder(
      builder: (context) => LButton(
        label: 'Show toast',
        onPressed: () => LToast.show(context, 'Moved to tomorrow'),
      ),
    ),
  );

  goldenOverlayMatrix(
    'l_confirm_dialog',
    triggerLabel: 'Delete',
    builder: () => Builder(
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
  );
}
