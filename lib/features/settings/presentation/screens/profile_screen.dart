import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/repositories/models/app_profile.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/settings/application/profile_settings_providers.dart';

/// §22.5's Profile section: name, week start, currency, date format.
/// Avatar upload isn't built (needs an image picker + local file storage
/// this pass doesn't add) — see DECISIONS.md.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncProfile = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Profile')),
      body: asyncProfile.when(
        loading: () => const Padding(padding: EdgeInsets.all(LifeSpace.s16), child: LLoadingShimmer(height: 200)),
        error: (error, stack) => Center(
          child: Text("Couldn't load your profile.", style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
        ),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return _ProfileForm(key: ValueKey(profile.id), profile: profile);
        },
      ),
    );
  }
}

const _currencies = ['GBP', 'USD', 'EUR'];

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.profile, super.key});

  final AppProfile profile;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final _nameController = TextEditingController(text: widget.profile.displayName ?? '');
  late var _weekStart = widget.profile.weekStart;
  late var _currency = _currencies.contains(widget.profile.currency) ? widget.profile.currency : 'GBP';
  late var _dateFormat = widget.profile.dateFormat;
  var _dirty = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    await saveProfile(
      ref,
      widget.profile.copyWith(displayName: name, weekStart: _weekStart, currency: _currency, dateFormat: _dateFormat),
    );
    setState(() => _dirty = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(LifeSpace.s16),
      children: [
        LTextField(
          controller: _nameController,
          label: 'Name',
          outlined: true,
          onChanged: (_) => setState(() => _dirty = true),
        ),
        const SizedBox(height: LifeSpace.s24),
        const LSectionHeader(title: 'Week starts on'),
        const SizedBox(height: LifeSpace.s8),
        LSegmented<int>(
          segments: const {1: 'Monday', 7: 'Sunday'},
          selected: _weekStart,
          onChanged: (v) => setState(() {
            _weekStart = v;
            _dirty = true;
          }),
        ),
        const SizedBox(height: LifeSpace.s24),
        const LSectionHeader(title: 'Currency'),
        const SizedBox(height: LifeSpace.s8),
        LSegmented<String>(
          segments: const {'GBP': '£ GBP', 'USD': r'$ USD', 'EUR': '€ EUR'},
          selected: _currency,
          onChanged: (v) => setState(() {
            _currency = v;
            _dirty = true;
          }),
        ),
        const SizedBox(height: LifeSpace.s24),
        const LSectionHeader(title: 'Date format'),
        const SizedBox(height: LifeSpace.s8),
        LSegmented<String>(
          segments: const {'dmy': '28/08/2026', 'mdy': '08/28/2026'},
          selected: _dateFormat,
          onChanged: (v) => setState(() {
            _dateFormat = v;
            _dirty = true;
          }),
        ),
        const SizedBox(height: LifeSpace.s24),
        LButton(label: 'Save', onPressed: _dirty ? _save : null),
      ],
    );
  }
}
