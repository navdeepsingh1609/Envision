import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LiquidSegmentedControl<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final double height;
  final double fontSize;

  const LiquidSegmentedControl({
    super.key,
    required this.values,
    required this.labels,
    required this.selectedValue,
    required this.onSelected,
    this.height = 48,
    this.fontSize = 12,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = values.indexOf(selectedValue);
    
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double segmentWidth = (constraints.maxWidth) / values.length;
          
          return Stack(
            children: [
              // Sliding rounded bubble
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                left: selectedIndex * segmentWidth,
                width: segmentWidth,
                height: height - 10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Labels
              Row(
                children: List.generate(values.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onSelected(values[index]),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white38,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          child: Text(labels[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
