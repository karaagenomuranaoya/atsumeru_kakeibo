import 'package:flutter/material.dart';
import '../models/category_tag.dart';

class CategorySelector extends StatelessWidget {
  final List<CategoryTag> tags;
  final int? selectedIndex;
  final int rowCount;
  final Function(int) onSelected;

  const CategorySelector({
    super.key,
    required this.tags,
    required this.selectedIndex,
    required this.rowCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowCount == 2 ? 100 : 50,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rowCount,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: rowCount == 2 ? 0.45 : 0.4,
        ),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedIndex == index;
          return ChoiceChip(
            label: Text(tag.label, style: const TextStyle(fontSize: 12)),
            selected: isSelected,
            onSelected: (_) => onSelected(index),
            shape: tag.isCircle
                ? const StadiumBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
            selectedColor: tag.color.withOpacity(0.3),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
