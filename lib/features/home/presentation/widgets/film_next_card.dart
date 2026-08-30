import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/media/tmdb_metadata_provider.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// §5.3's `filmNext` — the next scheduled film, poster and all. Tap opens
/// the plan it belongs to (not the occurrence sheet itself — that's a
/// `plans/`-feature widget, off-limits to import from `home/` per rule 4;
/// the plan's own Upcoming section is one tap further but reaches the
/// same place, same trade-off §16.5's "Schedule this" already made).
class FilmNextCard extends StatelessWidget {
  const FilmNextCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final item = snapshot.filmNext;
    if (item == null) return const SizedBox.shrink();

    final posterPath = item.libraryItem.posterPath;
    final imageProvider = posterPath == null || posterPath.isEmpty
        ? null
        : CachedNetworkImageProvider(TmdbMetadataProvider().imageUrl(posterPath, ImageSize.thumbnail).toString());
    final date = item.occurrence.scheduledDate;

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Next film'),
          LListTile(
            leading: LPosterTile(width: 40, imageProvider: imageProvider),
            title: item.libraryItem.title,
            subtitle: '${_weekdayNames[date.isoWeekday - 1]} ${date.day} ${_monthNames[date.month - 1]}',
            onTap: () => context.push(Routes.planDetail.replaceFirst(':id', item.plan.id)),
          ),
        ],
      ),
    );
  }
}
