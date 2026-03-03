import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_font.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(
      this.text,
      {
        Key? key,
        this.trimLines = 2,
        this.scrollController,
      })  : assert(text != null),
        super(key: key);

  final String text;
  final int trimLines;
  final ScrollController? scrollController;

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  RxBool _readMore = true.obs;
  void _onTapLink() {

    _readMore.value = !_readMore.value;
    if( !_readMore.value && widget.scrollController !=null)
      widget.scrollController!.animateTo(
        widget.scrollController!.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    _readMore.refresh();
  }

  @override
  Widget build(BuildContext context) {

    final colorClickableText = AppColors.primaryColor;
    final widgetColor = AppColors.jobRequestTextColor;

    // Widget result =
    return Obx(() =>_readMore.value ? LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        TextSpan link =
        TextSpan(
            text: _readMore.value ? "view_more".tr : ' ${"view_less".tr}',
            style: TextStyle(
                color: colorClickableText,
                fontFamily: AppFont.font
            ),
            recognizer: TapGestureRecognizer()..onTap = _onTapLink
        );
        // Create a TextSpan with data
        final text = TextSpan(
          text: widget.text,
        );
        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: TextDirection.rtl,//better to pass this from master widget if ltr and rtl both supported
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        // Get the endIndex of data
        int endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset) ??0;
        var textSpan;
        if (widget.text.length>70) {
          textSpan = TextSpan(
            text: _readMore.value
                ? "${widget.text.substring(0, 67)}..."
                : widget.text,
            style: TextStyle(
                color: widgetColor,
                fontSize: AppDimen.textSize_16,
                fontFamily: AppFont.font

            ),
            children: <TextSpan>[link],
          );
        } else {
          textSpan = TextSpan(
              text: widget.text,
              style: TextStyle(
                  color: widgetColor,
                  fontSize: AppDimen.textSize_16,
                  fontFamily: AppFont.font
              )
          );
        }
        return
          RichText(
            softWrap: true,
            overflow: TextOverflow.clip,
            text: textSpan,

          );
      },
    ):LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        TextSpan link =
        TextSpan(
            text: _readMore.value ? "view_more".tr : ' ${"view_less".tr}',
            style: TextStyle(
                color: colorClickableText,
                fontFamily: AppFont.font
            ),
            recognizer: TapGestureRecognizer()..onTap = _onTapLink
        );
        // Create a TextSpan with data
        final text = TextSpan(
          text: widget.text,
        );
        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: TextDirection.rtl,//better to pass this from master widget if ltr and rtl both supported
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        // Get the endIndex of data
        int endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset)!;
        var textSpan;
        if (widget.text.length>70) {
          textSpan = TextSpan(
            text: _readMore.value
                ? "${widget.text.substring(0, 67)}..."
                : widget.text,
            style: TextStyle(
                color: widgetColor,
                fontSize: AppDimen.textSize_16,
                fontFamily: AppFont.font
            ),
            children: <TextSpan>[link],
          );
        } else {
          textSpan = TextSpan(
              text: widget.text,
              style: TextStyle(
                  color: widgetColor,
                  fontSize: AppDimen.textSize_16,
                  fontFamily: AppFont.font
              )
          );
        }
        return
          RichText(
            softWrap: true,
            overflow: TextOverflow.clip,
            text: textSpan,

          );
      },

    ),
    );
    // return   result;
  }
}