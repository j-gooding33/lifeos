import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/contrast.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';

/// §2.9: "Add a golden test that asserts contrast for every token pair in
/// both themes." `ink3` (tertiary/disabled text) is intentionally excluded
/// — WCAG exempts disabled content from contrast requirements, and the
/// token doc itself names it "disabled" (§2.2).
void main() {
  for (final scheme in LifeThemeScheme.values) {
    final colors = LifeColors.forScheme(scheme);
    final neutrals = colors.neutrals;
    final surfaces = {
      'bg': neutrals.bg,
      'surface': neutrals.surface,
      'surfaceAlt': neutrals.surfaceAlt,
      'surfaceSunken': neutrals.surfaceSunken,
    };
    final texts = {'ink': neutrals.ink, 'ink2': neutrals.ink2};

    for (final surfaceEntry in surfaces.entries) {
      for (final textEntry in texts.entries) {
        test('${scheme.label}: ${textEntry.key} on ${surfaceEntry.key} meets 4.5:1', () {
          final ratio = contrastRatio(textEntry.value, surfaceEntry.value);
          expect(ratio, greaterThanOrEqualTo(4.5), reason: 'ratio was $ratio');
        });
      }
    }

    test('${scheme.label}: accent base/on meets 4.5:1', () {
      expect(contrastRatio(colors.accent.base, colors.accent.on), greaterThanOrEqualTo(4.5));
    });
  }

  for (final brightness in Brightness.values) {
    final neutrals = brightness == Brightness.dark ? LifeNeutrals.dark : LifeNeutrals.light;
    final surfaces = {
      'bg': neutrals.bg,
      'surface': neutrals.surface,
      'surfaceAlt': neutrals.surfaceAlt,
      'surfaceSunken': neutrals.surfaceSunken,
    };
    final texts = {'ink': neutrals.ink, 'ink2': neutrals.ink2};

    for (final surfaceEntry in surfaces.entries) {
      for (final textEntry in texts.entries) {
        test(
          '${textEntry.key} on ${surfaceEntry.key} meets 4.5:1 ($brightness)',
          () {
            final ratio = contrastRatio(textEntry.value, surfaceEntry.value);
            expect(ratio, greaterThanOrEqualTo(4.5), reason: 'ratio was $ratio');
          },
        );
      }
    }

    for (final name in LifeAccentName.values) {
      test('accent $name base/on meets 4.5:1 ($brightness)', () {
        final accent = LifeAccents.of(name, brightness);
        expect(contrastRatio(accent.base, accent.on), greaterThanOrEqualTo(4.5));
      });
    }

    for (final entry in LifeDomainColors.all(brightness).entries) {
      test('domain ${entry.key} base/on meets 4.5:1 ($brightness)', () {
        expect(contrastRatio(entry.value.base, entry.value.on), greaterThanOrEqualTo(4.5));
      });
    }

    for (final entry in LifeSemanticColors.all(brightness).entries) {
      test('semantic ${entry.key} base/on meets 4.5:1 ($brightness)', () {
        expect(contrastRatio(entry.value.base, entry.value.on), greaterThanOrEqualTo(4.5));
      });
    }
  }
}
