import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A circular avatar (§2.7) — an image when provided, otherwise initials
/// on a soft accent background.
class LAvatar extends StatelessWidget {
  const LAvatar({required this.name, this.imageProvider, this.size = 40, super.key});

  final String name;
  final ImageProvider? imageProvider;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colors.accent.soft,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              _initials,
              style: context.textStyles.subhead.copyWith(color: colors.accent.base),
            )
          : null,
    );
  }
}
