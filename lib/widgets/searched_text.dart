import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';

/// Creates a text widget with a ability to highlight parts of itself with a different style.
///
/// Has to have a [InheritedSearchTerm] widget among its ancestors for search to function.
///
/// The [highlightStyle] parameter defines the style of substrings matched to the search term.
///
/// See [Text] widget for usage of other parameters.
class SearchedText extends Text {
  final TextStyle? highlightStyle;

  const SearchedText(
    String data, {
    Key? key,
    TextOverflow? overflow,
    int? maxLines,
    TextStyle? style,
    this.highlightStyle,
  }) : super(
          data,
          key: key,
          overflow: overflow,
          maxLines: overflow == TextOverflow.ellipsis ? 1 : maxLines,
          style: style,
        );

  @override
  Widget build(BuildContext context) {
    return SubstringHighlight(
      textAlign: TextAlign.start,
      text: data!,
      term: InheritedSearchTerm.of(context)?.searchTerm ?? "",
      overflow: overflow ?? DefaultTextStyle.of(context).overflow,
      textStyle: style ?? Theme.of(context).textTheme.bodyText2 ?? const TextStyle(),
      textStyleHighlight:
          highlightStyle ?? Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondary) ?? const TextStyle(),
    );
  }
}

/// An [InheritedWidget] that provides [SearchedText]s with the [searchTerm]
class InheritedSearchTerm extends InheritedWidget {
  final String searchTerm;

  const InheritedSearchTerm({
    Key? key,
    required this.searchTerm,
    required Widget child,
  }) : super(key: key, child: child);

  static InheritedSearchTerm? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<InheritedSearchTerm>();

  @override
  bool updateShouldNotify(InheritedSearchTerm oldWidget) => searchTerm != oldWidget.searchTerm;
}
