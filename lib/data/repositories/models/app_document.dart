/// §17.3. A locally-stored file's metadata. `storedName` is the internal
/// on-disk filename; users only ever see [title]/[originalName].
class AppDocument {
  AppDocument({
    required this.id,
    required this.userId,
    required this.title,
    required this.storedName,
    required this.originalName,
    required this.fileSizeBytes,
    this.mimeType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final String storedName;
  final String originalName;
  final int fileSizeBytes;
  final String? mimeType;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppDocument copyWith({String? title}) {
    return AppDocument(
      id: id,
      userId: userId,
      title: title ?? this.title,
      storedName: storedName,
      originalName: originalName,
      fileSizeBytes: fileSizeBytes,
      mimeType: mimeType,
      createdAt: createdAt,
    );
  }
}
