import 'package:flutter/material.dart';

TextBox measureTextBox(BuildContext context, String text, TextStyle textStyle,
    int maxLines, TextOverflow overflow, BoxConstraints constraints) {
  final textSpan = TextSpan(
    text: text,
    style: textStyle,
  );

  final richTextWidget = Text.rich(
    textSpan,
    maxLines: maxLines,
    overflow: overflow,
  ).build(context) as RichText;

  final renderObject = richTextWidget.createRenderObject(context);

  renderObject.layout(constraints);

  final boxesForSelection = renderObject.getBoxesForSelection(TextSelection(
      baseOffset: 0, extentOffset: richTextWidget.text.toPlainText().length));

  if (boxesForSelection.isEmpty) {
    return const TextBox.fromLTRBD(0.0, 0.0, 0.0, 0.0, TextDirection.ltr);
  }

  final List<double> widths = [];

  for (var box in boxesForSelection) {
    widths.add(box.right);
  }

  widths.sort((a, b) => a.compareTo(b));

  return TextBox.fromLTRBD(
      0.0, 0.0, widths.last, boxesForSelection.last.bottom, TextDirection.ltr);
}
