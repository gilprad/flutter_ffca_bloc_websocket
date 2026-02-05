import 'package:flutter/material.dart';

class SymbolSelector extends StatelessWidget {
  const SymbolSelector({
    super.key,
    required this.symbols,
    required this.selected,
    required this.onSelected,
  });

  final List<String> symbols;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in symbols)
          ChoiceChip(
            label: Text(s),
            selected: s == selected,
            onSelected: (_) => onSelected(s),
          ),
      ],
    );
  }
}
