import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nepali_utils_example/state/settings.dart';

/// Copies [text] and confirms it with a snack bar.
Future<void> copyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${context.tr('Copied', 'कपी भयो')}: $text',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}

/// A scrollable page of section cards. Wide windows get two columns.
class const ToolPage({required final List<Widget> children, super.key})
    extends StatelessWidget {
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 920;
        final horizontal = constraints.maxWidth < 600 ? 16.0 : 24.0;
        final Widget content;
        if (wide) {
          final left = <Widget>[];
          final right = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            (i.isEven ? left : right).add(children[i]);
          }
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _column(left)),
              const SizedBox(width: _gap),
              Expanded(child: _column(right)),
            ],
          );
        } else {
          content = _column(children);
        }
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: content,
            ),
          ),
        );
      },
    );
  }

  Widget _column(List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: _gap),
        items[i],
      ],
    ],
  );
}

/// A card with a heading, used for every section of a tool.
class const SectionCard({
  required final String title,
  required final Widget child,
  final IconData? icon,
  final String? subtitle,
  final Widget? trailing,
  final Color? color,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// A labelled result. Tap it to copy the value.
class const ResultTile({
  required final String label,
  required final String value,

  /// Shows the value larger, on the primary container color.
  final bool emphasis = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = emphasis ? scheme.onPrimaryContainer : scheme.onSurface;
    return Material(
      color: emphasis ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(emphasis ? 24 : 16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: value.isEmpty ? null : () => copyToClipboard(context, value),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: emphasis ? 16 : 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: foreground.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value.isEmpty ? '—' : value,
                      style:
                          (emphasis
                                  ? theme.textTheme.headlineSmall
                                  : theme.textTheme.bodyLarge)
                              ?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.content_copy_rounded,
                size: 18,
                color: foreground.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A column of [ResultTile]s with small gaps.
class const ResultList({
  /// Label and value pairs.
  required final List<(String, String)> results,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, (label, value)) in results.indexed) ...[
        if (i > 0) const SizedBox(height: 8),
        ResultTile(label: label, value: value),
      ],
    ],
  );
}

/// An inline message, e.g. for invalid input.
class const InfoBanner({
  required final String message,
  final bool error = false,
  final IconData? icon,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = error
        ? scheme.errorContainer
        : scheme.secondaryContainer;
    final foreground = error
        ? scheme.onErrorContainer
        : scheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon ??
                (error
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded),
            color: foreground,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }
}

/// A numeric text field that accepts ASCII and Devanagari digits.
class const NumberField({
  required final TextEditingController controller,
  required final String label,
  final String? suffix,
  final ValueChanged<String>? onChanged,
  final bool autofocus = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: autofocus,
    onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, suffixText: suffix),
  );
}
