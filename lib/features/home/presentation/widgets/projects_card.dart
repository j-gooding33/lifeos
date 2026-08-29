import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §5.3's `projects` — up to 3 active projects with % complete.
class ProjectsCard extends StatelessWidget {
  const ProjectsCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.projects.isEmpty) return const SizedBox.shrink();

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Projects'),
          for (final item in snapshot.projects)
            LListTile(
              leading: const Icon(Icons.folder_outlined),
              title: item.project.title,
              subtitle: item.progress == null ? 'No tasks yet' : '${(item.progress! * 100).round()}% done',
              onTap: () => context.push(Routes.projectDetail.replaceFirst(':id', item.project.id)),
            ),
        ],
      ),
    );
  }
}
