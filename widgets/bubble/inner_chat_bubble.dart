import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class InnerChatBubble extends SingleChildRenderObjectWidget {
  final TextPainter textPainter;
  final TextPainter? nameTextPainter;
  final int maxChatBubbleWidthPercentage;
  final bool isRTL;

  const InnerChatBubble({
    Key? key,
    required this.textPainter,
    this.nameTextPainter,
    required this.isRTL,
    required this.maxChatBubbleWidthPercentage,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderInnerChatBubble(
        textPainter, nameTextPainter, maxChatBubbleWidthPercentage, isRTL);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderInnerChatBubble renderObject) {
    renderObject
      ..textPainter = textPainter
      ..nameTextPainter = nameTextPainter
      ..maxChatBubbleWidthPercentage = maxChatBubbleWidthPercentage
      ..isRTL = isRTL;
  }
}

class RenderInnerChatBubble extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  TextPainter _textPainter;
  TextPainter? _nameTextPainter;
  int _maxChatBubbleWidthPercentage;
  double _lastLineHeight = 0;
  bool _isRTL;

  RenderInnerChatBubble(TextPainter textPainter, TextPainter? nameTextPainter,
      int maxChatBubbleWidthPercentage, isRTL)
      : _textPainter = textPainter,
        _nameTextPainter = nameTextPainter,
        _maxChatBubbleWidthPercentage = maxChatBubbleWidthPercentage,
        _isRTL = isRTL;

  TextPainter get textPainter => _textPainter;
  set textPainter(TextPainter value) {
    if (_textPainter == value) return;
    _textPainter = value;
    markNeedsLayout();
  }

  TextPainter? get nameTextPainter => _nameTextPainter;
  set nameTextPainter(TextPainter? value) {
    if (_nameTextPainter == value) return;
    _nameTextPainter = value;
    markNeedsLayout();
  }

  bool get isRTL => _isRTL;
  set isRTL(bool value) {
    if (_isRTL == value) return;
    _isRTL = value;
    markNeedsLayout();
  }

  int get maxChatBubbleWidthPercentage => _maxChatBubbleWidthPercentage;
  set maxChatBubbleWidthPercentage(int value) {
    if (_maxChatBubbleWidthPercentage == value) return;
    _maxChatBubbleWidthPercentage = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    // Layout child and calculate size
    size = _performLayout(
      constraints: constraints,
      dry: false,
    );

    // Position child
    final BoxParentData childParentData = child!.parentData as BoxParentData;
    childParentData.offset = Offset(
        size.width - child!.size.width, textPainter.height - _lastLineHeight);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _performLayout(constraints: constraints, dry: true);
  }

  Size _performLayout({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    final BoxConstraints constraints =
        this.constraints * (_maxChatBubbleWidthPercentage / 100);
    late final Size childSize;
    if (child != null) {
      if (!dry) {
        child!.layout(BoxConstraints(maxWidth: constraints.maxWidth),
            parentUsesSize: true);
        childSize = child!.size;
      } else {
        childSize =
            child!.getDryLayout(BoxConstraints(maxWidth: constraints.maxWidth));
      }
    }

    double height;
    double width;
    textPainter.layout(minWidth: 0, maxWidth: constraints.maxWidth);
    height = textPainter.height;
    width = textPainter.width;

    if (nameTextPainter != null) {
      nameTextPainter!.layout(minWidth: 0, maxWidth: constraints.maxWidth);
      height += nameTextPainter!.height;
    }
    // Compute the LineMetrics of our textPainter
    final List<ui.LineMetrics> lines = textPainter.computeLineMetrics();
    // We are only interested in the last line's width
    final lastLineWidth = lines.last.width;
    _lastLineHeight = lines.last.height;

    // Layout child and assign size of RenderBox
    if (child != null) {
      final horizontalSpaceExceeded =
          lastLineWidth + childSize.width > constraints.maxWidth;

      if (horizontalSpaceExceeded) {
        height += childSize.height;
        _lastLineHeight = 0;
      } else {
        height += childSize.height - _lastLineHeight;
      }
      if (!isRTL) {
        if ((lines.length == 1 || width < childSize.width) &&
            !horizontalSpaceExceeded) {
          width += childSize.width;
        }
      } else {
        if (lines.length == 1) {
          width = width + childSize.width;
        }
      }
    }
    return Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final parentData = child!.parentData as BoxParentData;
      double nameTextPainterheight = 0.0;

      if (nameTextPainter != null) {
        nameTextPainterheight = nameTextPainter!.size.height;
      }

      // Paint the child (i.e. the row with the messageTime and Icon)

      if (_isRTL) {
        final List<ui.LineMetrics> lines = textPainter.computeLineMetrics();

        textPainter.paint(
            context.canvas,
            Offset(
                lines.length == 1 ? offset.dx + child!.size.width : offset.dx,
                offset.dy + nameTextPainterheight));
        context.paintChild(
            child!,
            Offset(offset.dx,
                offset.dy + parentData.offset.dy + nameTextPainterheight));
        if (nameTextPainter != null) {
          nameTextPainter!.paint(
              context.canvas,
              Offset(
                  offset.dx +
                      parentData.offset.dx -
                      nameTextPainter!.size.width +
                      child!.size.width,
                  offset.dy));
        }
      } else {
        textPainter.paint(context.canvas,
            Offset(offset.dx, offset.dy + nameTextPainterheight));
        context.paintChild(
            child!,
            Offset(offset.dx + parentData.offset.dx,
                offset.dy + parentData.offset.dy + nameTextPainterheight));
        if (nameTextPainter != null) {
          nameTextPainter!.paint(context.canvas, offset);
        }
      }
    } else {
      textPainter.paint(context.canvas, offset);
    }
  }
}
