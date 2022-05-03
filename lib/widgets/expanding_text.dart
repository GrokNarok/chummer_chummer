import 'package:flutter/material.dart';

import 'package:chummer_chummer/widgets/searched_text.dart';

/// Allows to expand or collapse text by swapping between contained [Text] widgets
/// [collapsed] should have fewer [maxLines] than [expanded]
class ExpandingText extends StatefulWidget {
  final Text collapsed;
  final Text expanded;
  final bool initiallyExpanded;
  final Duration duration;
  final double iconSize;

  /// If set to [true] this widget will automatically expand if [expanded] contains the search term specified in [InheritedSearchTerm]
  final bool expandOnSearchHit;

  const ExpandingText({
    Key? key,
    required this.collapsed,
    required this.expanded,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 300),
    this.iconSize = 18.0,
    this.expandOnSearchHit = true,
  }) : super(key: key);

  @override
  _ExpandingTextState createState() => _ExpandingTextState();
}

class _ExpandingTextState extends State<ExpandingText> with TickerProviderStateMixin {
  late bool _isExpandedByUser = widget.initiallyExpanded;

  @override
  Widget build(BuildContext _) => LayoutBuilder(builder: (context, size) {
        final textPainter = TextPainter(
          text: widget.collapsed.textSpan ?? TextSpan(text: widget.collapsed.data, style: widget.collapsed.style ?? DefaultTextStyle.of(context).style),
          textDirection: Directionality.of(context),
          maxLines: widget.collapsed.maxLines,
        )..layout(maxWidth: size.maxWidth - widget.iconSize);

        // If the collapsed text doesn't actually exceed it's maximum lines don't bother with expansion.
        if (!textPainter.didExceedMaxLines) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: widget.iconSize,
                height: widget.iconSize,
                child: Icon(Icons.circle, size: (widget.iconSize.round() ~/ 3).toDouble()), // Do third of the icon size but round to nearest 3
              ),
              widget.collapsed,
            ],
          );
        } else {
          bool isExpandedBySearch = false;
          if (widget.expandOnSearchHit && widget.expanded is SearchedText) {
            final searchTerm = InheritedSearchTerm.of(context)?.searchTerm.toLowerCase();
            final text = widget.expanded.data?.toLowerCase(); // SearchedText can't be rich so this will be set.
            isExpandedBySearch = searchTerm != null && searchTerm.isNotEmpty && text != null && text.contains(searchTerm);
          }

          final isExpanded = _isExpandedByUser || isExpandedBySearch;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpandedByUser = !_isExpandedByUser),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: widget.iconSize,
                  ),
                  Expanded(
                    child: AnimatedCrossFade(
                      firstCurve: const Threshold(0.0001),
                      secondCurve: const Threshold(0.0001),
                      duration: widget.duration,
                      firstChild: widget.collapsed,
                      secondChild: widget.expanded,
                      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      });
}
