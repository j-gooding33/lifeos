import 'package:flutter/material.dart';
import 'package:life_os/data/media/open_library_provider.dart';
import 'package:life_os/data/media/tmdb_metadata_provider.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// §22.5: "each shows connected/not configured honestly." Reads
/// `isConfigured` straight off the real provider classes — the same ones
/// Films/TV/Books search actually uses — rather than a separate status
/// flag that could drift from reality.
class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tmdbConfigured = TmdbMetadataProvider().isConfigured;
    final openLibraryConfigured = OpenLibraryProvider().isConfigured;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Integrations')),
      body: ListView(
        children: [
          LListTile(
            title: 'TMDB',
            subtitle: tmdbConfigured ? 'Connected — powers Films and TV search.' : 'Not configured — Films and TV search are disabled.',
            trailing: _StatusDot(connected: tmdbConfigured),
          ),
          LListTile(
            title: 'Open Library',
            subtitle: openLibraryConfigured ? 'Connected — powers Books search.' : 'Not configured — Book search is disabled.',
            trailing: _StatusDot(connected: openLibraryConfigured),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = connected ? colors.semantic('success').base : colors.neutrals.ink3;
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
