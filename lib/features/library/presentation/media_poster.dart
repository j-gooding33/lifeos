import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/features/library/application/library_providers.dart';

/// §16.7: cached posters, and a null return (never a broken image) when
/// there's no path — `LPosterTile` already renders an honest placeholder
/// for that case.
ImageProvider? posterImageFor(WidgetRef ref, MediaType type, String? posterPath) {
  if (posterPath == null || posterPath.isEmpty) return null;
  final provider = mediaProviderFor(ref, type);
  return CachedNetworkImageProvider(provider.imageUrl(posterPath, ImageSize.medium).toString());
}
