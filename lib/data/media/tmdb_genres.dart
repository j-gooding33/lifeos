/// TMDB's published genre taxonomy (`/genre/movie/list`, `/genre/tv/list`).
/// These lists are TMDB's stable, public genre vocabulary — embedding them
/// avoids an extra round trip on every search purely to resolve the
/// `genre_ids` a search result returns. This is not "bulk-caching their
/// catalogue" (§16.2's actual restriction): it's a fixed, small taxonomy,
/// not user content or search results.
const tmdbMovieGenres = <int, String>{
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Sci-Fi',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

const tmdbTvGenres = <int, String>{
  10759: 'Action & Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  10762: 'Kids',
  9648: 'Mystery',
  10763: 'News',
  10764: 'Reality',
  10765: 'Sci-Fi & Fantasy',
  10766: 'Soap',
  10767: 'Talk',
  10768: 'War & Politics',
  37: 'Western',
};

List<String> tmdbMovieGenreNames(List<int> ids) => [
  for (final id in ids)
    if (tmdbMovieGenres[id] != null) tmdbMovieGenres[id]!,
];

List<String> tmdbTvGenreNames(List<int> ids) => [
  for (final id in ids)
    if (tmdbTvGenres[id] != null) tmdbTvGenres[id]!,
];
