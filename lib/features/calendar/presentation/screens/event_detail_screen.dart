import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_event.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_time_picker.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/calendar/application/calendar_providers.dart';

/// §14. Create/edit an event — one screen for both, same pattern as
/// `TaskDetailScreen`. Drag-to-move and the fixed/rolling explainer for
/// plan occurrences (§14.3) live on the calendar view, not here.
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({this.eventId, this.initialDate, super.key});

  final String? eventId;
  final DateTime? initialDate;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  late DateTime _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  var _allDay = false;

  var _loaded = false;
  AppEvent? _existing;

  bool get _isNew => widget.eventId == null;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime date, TimeOfDay? time) {
    if (time == null) return DateTime(date.year, date.month, date.day);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final userId = await ref.read(currentUserIdProvider.future);
    final repository = ref.read(eventRepositoryProvider);
    final startAt = _combine(_startDate, _allDay ? null : _startTime);
    final endAt = _endDate == null
        ? null
        : _combine(_endDate!, _allDay ? null : _endTime);

    if (_existing != null) {
      await repository.updateEvent(
        _existing!.copyWith(
          title: title,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          startAt: startAt,
          endAt: endAt,
          clearEndAt: endAt == null,
          allDay: _allDay,
        ),
      );
    } else {
      await repository.createEvent(
        userId: userId,
        title: title,
        startAt: startAt,
        endAt: endAt,
        allDay: _allDay,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
      );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNew) return _buildForm(context);

    final asyncEvent = ref.watch(eventByIdProvider(widget.eventId!));
    return asyncEvent.when(
      loading: () =>
          const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: const LErrorState(message: "Couldn't load this event."),
      ),
      data: (event) {
        if (event == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const LErrorState(message: 'This event no longer exists.'),
          );
        }
        if (!_loaded) {
          _existing = event;
          _titleController.text = event.title;
          _notesController.text = event.notes ?? '';
          _locationController.text = event.location ?? '';
          _startDate = event.startAt;
          _startTime = event.allDay
              ? null
              : TimeOfDay.fromDateTime(event.startAt);
          _endDate = event.endAt;
          _endTime = event.allDay || event.endAt == null
              ? null
              : TimeOfDay.fromDateTime(event.endAt!);
          _allDay = event.allDay;
          _loaded = true;
        }
        if (event.isFromDevice) return _DeviceEventView(event: event);
        return _buildForm(context, event: event);
      },
    );
  }

  Widget _buildForm(BuildContext context, {AppEvent? event}) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Text(_isNew ? 'New event' : 'Event'),
        actions: [
          if (event != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete event',
              onPressed: () async {
                final confirmed = await LConfirmDialog.show(
                  context,
                  title: 'Delete this event?',
                  message: 'This cannot be undone.',
                );
                if (confirmed) {
                  await ref.read(eventRepositoryProvider).deleteEvent(event.id);
                  if (context.mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s20),
        children: [
          LTextField(controller: _titleController, placeholder: 'Event title'),
          const SizedBox(height: LifeSpace.s12),
          Row(
            children: [
              Text(
                'All day',
                style: context.textStyles.body.copyWith(
                  color: colors.neutrals.ink,
                ),
              ),
              const Spacer(),
              Switch(
                value: _allDay,
                onChanged: (v) => setState(() => _allDay = v),
              ),
            ],
          ),
          const SizedBox(height: LifeSpace.s12),
          Row(
            children: [
              Expanded(
                child: LDatePicker(
                  date: _startDate,
                  onChanged: (d) => setState(() => _startDate = d),
                ),
              ),
              if (!_allDay) ...[
                const SizedBox(width: LifeSpace.s8),
                Expanded(
                  child: LTimePicker(
                    time: _startTime,
                    onChanged: (t) => setState(() => _startTime = t),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: LifeSpace.s12),
          Row(
            children: [
              Expanded(
                child: LDatePicker(
                  date: _endDate,
                  firstDate: _startDate,
                  onChanged: (d) => setState(() => _endDate = d),
                ),
              ),
              if (!_allDay) ...[
                const SizedBox(width: LifeSpace.s8),
                Expanded(
                  child: LTimePicker(
                    time: _endTime,
                    onChanged: (t) => setState(() => _endTime = t),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: LifeSpace.s12),
          LTextField(controller: _locationController, placeholder: 'Location'),
          const SizedBox(height: LifeSpace.s12),
          LTextField(controller: _notesController, placeholder: 'Notes'),
          const SizedBox(height: LifeSpace.s24),
          LButton(label: _isNew ? 'Create' : 'Save', onPressed: _save),
        ],
      ),
    );
  }
}

/// §14.4: imported events are "rendered in grey, and are not editable in
/// Life OS" — no title field, no delete button, since either would imply
/// a change that the next device-calendar sync would just silently undo.
class _DeviceEventView extends StatelessWidget {
  const _DeviceEventView({required this.event});

  final AppEvent event;

  String _time(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = context.textStyles.caption.copyWith(color: colors.neutrals.ink2);
    final valueStyle = context.textStyles.body.copyWith(color: colors.neutrals.ink);
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Event')),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s20),
        children: [
          LCard(
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: colors.neutrals.ink2),
                const SizedBox(width: LifeSpace.s8),
                Expanded(
                  child: Text(
                    'Imported from your device calendar. Edit it there — changes made here would be overwritten on the next sync.',
                    style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: LifeSpace.s16),
          Text(event.title, style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
          const SizedBox(height: LifeSpace.s20),
          Text('When', style: labelStyle),
          const SizedBox(height: LifeSpace.s4),
          Text(
            event.allDay
                ? 'All day, ${event.startDate.toIso()}'
                : event.endAt == null
                ? '${event.startDate.toIso()} at ${_time(event.startAt)}'
                : '${event.startDate.toIso()} ${_time(event.startAt)} – ${_time(event.endAt!)}',
            style: valueStyle,
          ),
          if (event.location != null) ...[
            const SizedBox(height: LifeSpace.s16),
            Text('Location', style: labelStyle),
            const SizedBox(height: LifeSpace.s4),
            Text(event.location!, style: valueStyle),
          ],
          if (event.notes != null) ...[
            const SizedBox(height: LifeSpace.s16),
            Text('Notes', style: labelStyle),
            const SizedBox(height: LifeSpace.s4),
            Text(event.notes!, style: valueStyle),
          ],
        ],
      ),
    );
  }
}
