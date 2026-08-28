import 'package:flutter/material.dart';
import 'package:life_os/design/components/l_text_field.dart';

/// A single-line text prompt dialog (§2.7-adjacent) — "New collection,"
/// "Rename," "New milestone," and similar one-field confirmations all
/// share this exact shape. Returns the trimmed text, or `null` if the
/// user cancelled or left it empty — callers never need to check both.
class LPromptDialog {
  const LPromptDialog._();

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String label,
    String initialValue = '',
    String confirmLabel = 'Save',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: LTextField(controller: controller, label: label, outlined: true, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()), child: Text(confirmLabel)),
        ],
      ),
    );
    return (result == null || result.isEmpty) ? null : result;
  }
}
