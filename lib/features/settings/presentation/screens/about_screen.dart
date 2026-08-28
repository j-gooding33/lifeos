import 'package:flutter/material.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// §22.5. Privacy policy, terms and contact aren't linked — there's
/// nothing published yet to link to, and a dead/placeholder link is worse
/// than not showing the row (CLAUDE.md rule 1).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          return ListView(
            children: [
              LListTile(title: 'Version', subtitle: info == null ? '…' : '${info.version} (build ${info.buildNumber})'),
              LListTile(
                title: 'Licences',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(context: context, applicationName: 'Life OS'),
              ),
              Padding(
                padding: const EdgeInsets.all(LifeSpace.s16),
                child: Text(
                  'This product uses the TMDB API but is not endorsed or certified by TMDB. '
                  'Book data from Open Library.',
                  style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
