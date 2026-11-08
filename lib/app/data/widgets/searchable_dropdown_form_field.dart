import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A selection-only field: typing filters labels, while selection returns an ID.
/// Existing `DropdownMenuItem<Text>` callers keep validation and data IDs.
class SearchableDropdownFormField extends FormField<String> {
  SearchableDropdownFormField({
    super.key,
    super.initialValue,
    required this.items,
    required this.onChanged,
    this.decoration = const InputDecoration(),
    this.hint,
    this.style,
    this.icon,
    bool isExpanded = true,
    BorderRadius? borderRadius,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    bool autofocus = false,
  }) : super(
         enabled: onChanged != null,
         builder: (state) => (state as _SearchableDropdownState)._buildField(),
       );

  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?>? onChanged;
  final InputDecoration decoration;
  final Widget? hint;
  final TextStyle? style;
  final Widget? icon;

  @override
  FormFieldState<String> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends FormFieldState<String> {
  @override
  SearchableDropdownFormField get widget =>
      super.widget as SearchableDropdownFormField;

  @override
  void didUpdateWidget(covariant SearchableDropdownFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
    if (!widget.items.any((item) => item.value == value)) setValue(null);
  }

  Future<void> _open() async {
    if (!widget.enabled) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => _SearchOptionsDialog(
        title:
            widget.decoration.labelText ??
            widget.decoration.hintText ??
            'Pilih data',
        items: widget.items,
        selected: value,
      ),
    );
    if (!mounted || selected == null) return;
    if (!widget.items.any((item) => item.value == selected && item.enabled)) {
      return;
    }
    didChange(selected);
    widget.onChanged?.call(selected);
  }

  Widget _buildField() {
    final matches = widget.items.where((item) => item.value == value);
    final selected = matches.isEmpty ? null : matches.first;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      child: InkWell(
        onTap: widget.enabled ? _open : null,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: widget.decoration.copyWith(
            enabled: widget.enabled,
            errorText: errorText,
            hintText: '',
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          isEmpty: selected == null,
          child: Row(
            children: [
              Expanded(
                child: DefaultTextStyle.merge(
                  style: widget.style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child:
                      selected?.child ??
                      widget.hint ??
                      Text(widget.decoration.hintText ?? 'Pilih data'),
                ),
              ),
              const SizedBox(width: 8),
              widget.icon ?? const Icon(Icons.search_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

String searchableItemLabel(Widget child) {
  if (child is Text) return child.data ?? child.textSpan?.toPlainText() ?? '';
  if (child is RichText) return child.text.toPlainText();
  if (child is Row) return child.children.map(searchableItemLabel).join(' ');
  if (child is Column) return child.children.map(searchableItemLabel).join(' ');
  if (child is Flexible) return searchableItemLabel(child.child);
  return '';
}

class _SearchOptionsDialog extends StatefulWidget {
  const _SearchOptionsDialog({
    required this.title,
    required this.items,
    this.selected,
  });
  final String title;
  final List<DropdownMenuItem<String>> items;
  final String? selected;

  @override
  State<_SearchOptionsDialog> createState() => _SearchOptionsDialogState();
}

class _SearchOptionsDialogState extends State<_SearchOptionsDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = widget.items
        .where((item) {
          final label = searchableItemLabel(item.child).toLowerCase();
          return _query.split(RegExp(r'\s+')).every(label.contains);
        })
        .toList(growable: false);
    final media = MediaQuery.of(context);
    final height = math.max(
      160.0,
      math.min(480.0, media.size.height - media.viewInsets.bottom - 64),
    );
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tutup pilihan',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Cari pilihan',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: results.isEmpty
                      ? const Center(
                          child: Text('Tidak ada pilihan yang cocok.'),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final item = results[index];
                            return ListTile(
                              enabled: item.enabled,
                              title: item.child,
                              selected: item.value == widget.selected,
                              trailing: item.value == widget.selected
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: item.enabled
                                  ? () => Navigator.pop(context, item.value)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
