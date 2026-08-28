import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/search_repository.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/search/application/search_providers.dart';
import 'package:life_os/routing/routes.dart';

const _groupCap = 8;

const _typeLabels = {
  'task': 'Tasks',
  'note': 'Notes',
  'plan': 'Plans',
  'project': 'Projects',
  'goal': 'Goals',
  'event': 'Events',
  'journal': 'Journal',
  'film': 'Films',
  'tv': 'TV Shows',
  'book': 'Books',
  'link': 'Links',
};

const _typeIcons = {
  'task': Icons.check_circle_outline,
  'note': Icons.note_outlined,
  'plan': Icons.repeat_outlined,
  'project': Icons.folder_outlined,
  'goal': Icons.flag_outlined,
  'event': Icons.event_outlined,
  'journal': Icons.book_outlined,
  'film': Icons.movie_outlined,
  'tv': Icons.live_tv_outlined,
  'book': Icons.menu_book_outlined,
  'link': Icons.link,
};

/// §18: full-screen modal, results grouped by type with a count per group,
/// capped at 8 with "Show all." Semantic search (§18.3, Premium) isn't
/// built — keyword FTS only, offline-capable by construction since it's a
/// local SQLite query.
class UniversalSearchScreen extends ConsumerStatefulWidget {
  const UniversalSearchScreen({super.key});

  @override
  ConsumerState<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends ConsumerState<UniversalSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<SearchResultGroup> _groups = const [];
  var _loading = false;
  var _searched = false;
  final _expanded = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _groups = const [];
        _loading = false;
        _searched = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 250), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final groups = await ref.read(searchRepositoryProvider).search(query);
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loading = false;
      _searched = true;
    });
  }

  void _open(SearchResult result) {
    // Pop this screen before pushing the destination — it's a top-level
    // route sitting outside every shell branch, and pushing straight into
    // a branch-nested route (task/plan/project/... detail) while it's
    // still on the stack trips go_router's duplicate-page-key assertion.
    // Mirrors QuickAddSheet's pop-then-push, the only other place that
    // navigates into an arbitrary branch from outside the shell.
    context.pop();
    switch (result.entityType) {
      case 'task':
        context.push(Routes.taskDetail.replaceFirst(':id', result.entityId));
      case 'note':
        context.push(Routes.libraryNoteDetail.replaceFirst(':id', result.entityId));
      case 'plan':
        context.push(Routes.planDetail.replaceFirst(':id', result.entityId));
      case 'project':
        context.push(Routes.projectDetail.replaceFirst(':id', result.entityId));
      case 'goal':
        context.push(Routes.goalDetail.replaceFirst(':id', result.entityId));
      case 'event':
        context.push(Routes.calendarEvent.replaceFirst(':id', result.entityId));
      case 'journal':
        context.push(Routes.journalDate.replaceFirst(':date', result.entityId));
      case 'film':
        context.push(Routes.libraryFilmDetail.replaceFirst(':id', result.entityId));
      case 'tv':
        context.push(Routes.libraryTvDetail.replaceFirst(':id', result.entityId));
      case 'book':
        context.push(Routes.libraryBookDetail.replaceFirst(':id', result.entityId));
      case 'link':
        // No per-link detail route; the list is where it lives.
        context.push(Routes.libraryLinks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
          decoration: const InputDecoration(hintText: 'Search everything', border: InputBorder.none),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            ),
        ],
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(LifeColors colors) {
    if (!_searched && !_loading) {
      return const LEmptyState(
        icon: Icons.search,
        title: 'Search everything',
        message: 'Tasks, plans, projects, goals, notes, your library, journal and links — all in one place.',
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_groups.isEmpty) {
      return const LEmptyState(icon: Icons.search_off, title: 'No results', message: 'Try a different word.');
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
      children: [for (final group in _groups) _GroupSection(group: group, expanded: _expanded, onOpen: _open, onToggle: setState)],
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.group, required this.expanded, required this.onOpen, required this.onToggle});

  final SearchResultGroup group;
  final Set<String> expanded;
  final ValueChanged<SearchResult> onOpen;
  final void Function(VoidCallback) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isExpanded = expanded.contains(group.entityType);
    final visible = isExpanded ? group.results : group.results.take(_groupCap).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(LifeSpace.s16, LifeSpace.s12, LifeSpace.s16, LifeSpace.s4),
          child: Text(
            '${_typeLabels[group.entityType] ?? group.entityType} (${group.results.length})'.toUpperCase(),
            style: context.textStyles.micro.copyWith(color: colors.neutrals.ink3),
          ),
        ),
        for (final result in visible)
          LListTile(
            leading: Icon(_typeIcons[group.entityType] ?? Icons.circle_outlined),
            title: result.title.isEmpty ? '(untitled)' : result.title,
            subtitle: result.snippet.isEmpty ? null : result.snippet,
            onTap: () => onOpen(result),
          ),
        if (group.results.length > _groupCap && !isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16),
            child: TextButton(onPressed: () => onToggle(() => expanded.add(group.entityType)), child: const Text('Show all')),
          ),
      ],
    );
  }
}
