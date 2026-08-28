/// §17.3. A saved URL — "the link is saved instantly and enriched later"
/// (network-optional). Open Graph enrichment isn't built this pass, so
/// `title`/`faviconUrl` are whatever the user typed, or null.
class AppLink {
  AppLink({
    required this.id,
    required this.userId,
    required this.url,
    this.title,
    this.faviconUrl,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String url;
  final String? title;
  final String? faviconUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayTitle => (title?.isNotEmpty ?? false) ? title! : url;

  AppLink copyWith({String? title, bool clearTitle = false, List<String>? tags}) {
    return AppLink(
      id: id,
      userId: userId,
      url: url,
      title: clearTitle ? null : (title ?? this.title),
      faviconUrl: faviconUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt,
    );
  }
}
