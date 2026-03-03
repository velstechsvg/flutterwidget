// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:yottachat/resources/app_colors.dart';

import 'handy_text.dart';

const Duration _kExpand = Duration(milliseconds: 200);

/// A single-line [ListTile] with an expansion arrow icon that expands or collapses
/// the tile to reveal or hide the [children].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [CustomExpansionTile] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// This class overrides the [ListTileTheme.iconColor] and [ListTileTheme.textColor]
/// theme properties for its [ListTile]. These colors animate between values when
/// the tile is expanded and collapsed: between [iconColor], [collapsedIconColor] and
/// between [textColor] and [collapsedTextColor].
///
/// The expansion arrow icon is shown on the right by default in left-to-right languages
/// (i.e. the trailing edge). This can be changed using [controlAffinity]. This maps
/// to the [leading] and [trailing] properties of [CustomExpansionTile].
///
/// {@tool dartpad --template=stateful_widget_scaffold}
///
/// This example demonstrates different configurations of CustomExpansionTile.
///
/// ```dart
/// bool _customTileExpanded = false;
///
/// @override
/// Widget build(BuildContext context) {
///   return Column(
///     children: <Widget>[
///       const CustomExpansionTile(
///         title: Text('CustomExpansionTile 1'),
///         subtitle: Text('Trailing expansion arrow icon'),
///         children: <Widget>[
///           ListTile(title: Text('This is tile number 1')),
///         ],
///       ),
///       CustomExpansionTile(
///         title: const Text('CustomExpansionTile 2'),
///         subtitle: const Text('Custom expansion arrow icon'),
///         trailing: Icon(
///           _customTileExpanded
///               ? Icons.arrow_drop_down_circle
///               : Icons.arrow_drop_down,
///         ),
///         children: const <Widget>[
///           ListTile(title: Text('This is tile number 2')),
///         ],
///         onExpansionChanged: (bool expanded) {
///           setState(() => _customTileExpanded = expanded);
///         },
///       ),
///       const CustomExpansionTile(
///         title: Text('CustomExpansionTile 3'),
///         subtitle: Text('Leading expansion arrow icon'),
///         controlAffinity: ListTileControlAffinity.leading,
///         children: <Widget>[
///           ListTile(title: Text('This is tile number 3')),
///         ],
///       ),
///     ],
///   );
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile [children] when the
///    expansion tile represents a sublist.
///  * The "Expand and collapse" section of
///    <https://material.io/components/lists#types>
class CustomExpansionTile extends StatefulWidget {
  /// Creates a single-line [ListTile] with an expansion arrow icon that expands or collapses
  /// the tile to reveal or hide the [children]. The [initiallyExpanded] property must
  /// be non-null.
  const CustomExpansionTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.subCategoryPicture,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.titleStartPadding=0,
    this.titleBottomPadding=0,
    this.childStartPadding=0,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.childrenPadding,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.textColor,
    this.collapsedTextColor,
    this.iconColor,
    this.collapsedIconColor,
    this.controlAffinity, this.from="", this.titleBackGround, this.totalAmount, this.titleText, this.amount,
  }) : assert(initiallyExpanded != null),
        assert(maintainState != null),
        assert(
        expandedCrossAxisAlignment != CrossAxisAlignment.baseline,
        'CrossAxisAlignment.baseline is not supported since the expanded children '
            'are aligned in a column, not a row. Try to use another constant.',
        ),
        super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  ///
  /// Note that depending on the value of [controlAffinity], the [leading] widget
  /// may replace the rotating expansion arrow icon.
  final Widget? leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget? title;
  final String? titleText;
  final String? amount;

  final double? titleStartPadding;
  final double? titleBottomPadding;
  final double? childStartPadding;

  final String? from;
  final String? subCategoryPicture;
  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;


  final Color? titleBackGround;

  final bool? initiallyExpanded;
  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// The color to display behind the sublist when expanded.
  final Color? backgroundColor;


  final Widget? totalAmount;
  /// When not null, defines the background color of tile when the sublist is collapsed.
  final Color? collapsedBackgroundColor;

  /// A widget to display after the title.
  ///
  /// Note that depending on the value of [controlAffinity], the [trailing] widget
  /// may replace the rotating expansion arrow icon.
  final Widget? trailing;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).

  /// Specifies whether the state of the children is maintained when the tile expands and collapses.
  ///
  /// When true, the children are kept in the tree while the tile is collapsed.
  /// When false (default), the children are removed from the tree when the tile is
  /// collapsed and recreated upon expansion.
  final bool maintainState;

  /// Specifies padding for the [ListTile].
  ///
  /// Analogous to [ListTile.contentPadding], this property defines the insets for
  /// the [leading], [title], [subtitle] and [trailing] widgets. It does not inset
  /// the expanded [children] widgets.
  ///
  /// When the value is null, the tile's padding is `EdgeInsets.symmetric(horizontal: 16.0)`.
  final EdgeInsetsGeometry? tilePadding;

  /// Specifies the alignment of [children], which are arranged in a column when
  /// the tile is expanded.
  ///
  /// The internals of the expanded tile make use of a [Column] widget for
  /// [children], and [Align] widget to align the column. The `expandedAlignment`
  /// parameter is passed directly into the [Align].
  ///
  /// Modifying this property controls the alignment of the column within the
  /// expanded tile, not the alignment of [children] widgets within the column.
  /// To align each child within [children], see [expandedCrossAxisAlignment].
  ///
  /// The width of the column is the width of the widest child widget in [children].
  ///
  /// When the value is null, the value of `expandedAlignment` is [Alignment.center].
  final Alignment? expandedAlignment;

  /// Specifies the alignment of each child within [children] when the tile is expanded.
  ///
  /// The internals of the expanded tile make use of a [Column] widget for
  /// [children], and the `crossAxisAlignment` parameter is passed directly into the [Column].
  ///
  /// Modifying this property controls the cross axis alignment of each child
  /// within its [Column]. Note that the width of the [Column] that houses
  /// [children] will be the same as the widest child widget in [children]. It is
  /// not necessarily the width of [Column] is equal to the width of expanded tile.
  ///
  /// To align the [Column] along the expanded tile, use the [expandedAlignment] property
  /// instead.
  ///
  /// When the value is null, the value of `expandedCrossAxisAlignment` is [CrossAxisAlignment.center].
  final CrossAxisAlignment? expandedCrossAxisAlignment;

  /// Specifies padding for [children].
  ///
  /// When the value is null, the value of `childrenPadding` is [EdgeInsets.zero].
  final EdgeInsetsGeometry? childrenPadding;

  /// The icon color of tile's expansion arrow icon when the sublist is expanded.
  ///
  /// Used to override to the [ListTileTheme.iconColor].
  final Color? iconColor;

  /// The icon color of tile's expansion arrow icon when the sublist is collapsed.
  ///
  /// Used to override to the [ListTileTheme.iconColor].
  final Color? collapsedIconColor;


  /// The color of the tile's titles when the sublist is expanded.
  ///
  /// Used to override to the [ListTileTheme.textColor].
  final Color? textColor;

  /// The color of the tile's titles when the sublist is collapsed.
  ///
  /// Used to override to the [ListTileTheme.textColor].
  final Color? collapsedTextColor;

  /// Typically used to force the expansion arrow icon to the tile's leading or trailing edge.
  ///
  /// By default, the value of `controlAffinity` is [ListTileControlAffinity.platform],
  /// which means that the expansion arrow icon will appear on the tile's trailing edge.
  final ListTileControlAffinity? controlAffinity;

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween = CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<Color?> _borderColor;
  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _borderColor = _controller.drive(_borderColorTween.chain(_easeOutTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor = _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context)?.readState(context) as bool? ?? widget.initiallyExpanded?? false;
    if (_isExpanded)
      _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();

      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted)
            return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  // Platform or null affinity defaults to trailing.
  ListTileControlAffinity _effectiveAffinity(ListTileControlAffinity? affinity) {
    switch (affinity ?? ListTileControlAffinity.trailing) {
      case ListTileControlAffinity.leading:
        return ListTileControlAffinity.leading;
      case ListTileControlAffinity.trailing:
      case ListTileControlAffinity.platform:
        return ListTileControlAffinity.trailing;
    }
  }

  Widget? _buildIcon(BuildContext context) {
    return RotationTransition(
      turns: _iconTurns,
      child: const Icon(Icons.expand_more),
    );
  }

  Widget? _buildLeadingIcon(BuildContext context) {
    if (_effectiveAffinity(widget.controlAffinity) != ListTileControlAffinity.leading)
      return null;
    return _buildIcon(context);
  }

  Widget? _buildTrailingIcon(BuildContext context) {
    if (_effectiveAffinity(widget.controlAffinity) != ListTileControlAffinity.trailing)
      return null;
    return _buildIcon(context);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final Color borderSideColor = _borderColor.value ?? Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          child: widget.from=="multiple"?Container(
            child: viewSubCategory(),
          ):Container(
            padding: EdgeInsetsDirectional.only(start: widget.titleStartPadding ?? 0,bottom: widget.titleBottomPadding ?? 0),
            color: widget.titleBackGround,
            child: Row(
              children: [
                Expanded(
                  child:
                  Row(
                    children: [
                      widget.title ?? const SizedBox.shrink(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RotationTransition(
                          turns: _iconTurns,
                          child:  widget.leading,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                    padding: EdgeInsetsDirectional.only(start:5.0),
                    child: widget.totalAmount ?? const SizedBox.shrink())
              ],
            ),
          ),
          onTap: _handleTap,
        ),

        Container(
          padding: EdgeInsetsDirectional.only(start: widget.childStartPadding ?? 0.0),
          child: ClipRect(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    _borderColorTween.end = theme.dividerColor;
    _headerColorTween
      ..begin = widget.collapsedTextColor ?? theme.textTheme.titleMedium!.color
      ..end = widget.textColor ?? colorScheme.primary;
    _iconColorTween
      ..begin = widget.collapsedIconColor ?? theme.unselectedWidgetColor
      ..end = widget.iconColor ?? colorScheme.primary;
    _backgroundColorTween
      ..begin = widget.collapsedBackgroundColor
      ..end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    final bool shouldRemoveChildren = closed && !widget.maintainState;

    final Widget result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: Padding(
          padding: widget.childrenPadding ?? EdgeInsets.zero,
          child: Container(
            decoration:  BoxDecoration(
                borderRadius: const BorderRadiusDirectional.only(bottomEnd:Radius.circular(10)),
                color: widget.from=="multiple"? AppColors.white : widget.titleBackGround,
                boxShadow: const [
                  BoxShadow(
                      color: AppColors.dropShadow,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 5.0,
                      spreadRadius: 1.0
                  )
                ]
            ),
            child: Column(
              crossAxisAlignment: widget.expandedCrossAxisAlignment ?? CrossAxisAlignment.center,
              children: widget.children,
            ),
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: _buildChildren,
      child: shouldRemoveChildren ? null : result,
    );
  }


  Widget viewSubCategory(){
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 20),
      child: Container(
          padding: EdgeInsetsDirectional.only(top: 10, bottom: 10, start: 13, end: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.only(topStart: const Radius.circular(10),bottomEnd:Radius.circular( _isExpanded?0:10)),
              color: AppColors.white,
              boxShadow: const [
                BoxShadow(
                    color: AppColors.dropShadow,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 5.0,
                    spreadRadius: 1.0
                )
              ]
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: widget.subCategoryPicture !=null && widget.subCategoryPicture!=""? CachedNetworkImage(
                        imageUrl: widget.subCategoryPicture ?? "",
                        height: 50.0,
                        width: 50.0,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          "res/drawable/default_sub_category.png",
                          width: 50,
                          height: 50,
                          fit: BoxFit.scaleDown,
                        ),
                        // errorWidget: (context, url, error) => Icon(Icons.error),
                      ):Image.asset(
                        "res/drawable/default_sub_category.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:  [
                          CustomText(text: widget.titleText ?? "", fontWeight: FontWeight.bold,size: 16,),
                          const SizedBox(height: 10),
                          CustomText(text: widget.amount ?? "", color: AppColors.primaryColor,),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: RotationTransition(
                  turns: _iconTurns,
                  child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: widget.leading
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }


}
