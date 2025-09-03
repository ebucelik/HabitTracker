import 'package:flutter/material.dart';
import '../data/heatmap_color.dart';

class HeatMapContainer extends StatefulWidget {
  final DateTime date;
  final double? size;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final EdgeInsets? margin;
  final bool? showText;
  final bool? isSelected;
  final bool? isScaled;
  final bool? hasNote;
  final Function(DateTime dateTime)? onClick;
  final Function() onDoubleClick;

  const HeatMapContainer({
    Key? key,
    required this.date,
    this.margin,
    this.size,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.showText,
    this.isSelected,
    this.isScaled,
    this.hasNote,
    this.onClick,
    required this.onDoubleClick,
  }) : super(key: key);

  @override
  State<HeatMapContainer> createState() => _HeatMapContainerState();
}

class _HeatMapContainerState extends State<HeatMapContainer> {
  bool test = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: () =>
            widget.onClick != null ? widget.onClick!(widget.date) : null,
        onDoubleTap: () => widget.onDoubleClick(),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? HeatMapColor.defaultColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadius ?? 5),
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutQuad,
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.selectedColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(widget.borderRadius ?? 5),
                  ),
                  border: widget.isSelected == true
                      ? Border.all(
                          width: widget.isScaled == true ? 2 : 1,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                child: (widget.showText ?? true)
                    ? Text(
                        widget.date.day.toString(),
                        style: TextStyle(
                          color: widget.textColor ?? const Color(0xFF8A8A8A),
                          fontSize: widget.fontSize,
                        ),
                      )
                    : null,
              ),
            ),
            widget.hasNote == true
                ? Positioned(
                    top: widget.isScaled == true ? -2 : 0,
                    right: 1,
                    child: Icon(
                      Icons.bookmark,
                      size: widget.isScaled == true ? 18 : 6,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
