import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef StringPredicate = bool Function(String);

Future<String?> showTextInputDialogInternal(BuildContext context,
    {String? title, StringPredicate? predicate}) async {
  String? inputValue;
  bool isOk = false;

  if (predicate != null) {
    var clipData = await Clipboard.getData(Clipboard.kTextPlain);

    if (clipData != null && predicate(clipData.text!)) {
      inputValue = clipData.text!;
    }
  }

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title != null ? Text(title) : null,
        content: TextField(
          controller: TextEditingController(text: inputValue ?? ""),
          onChanged: (value) {
            inputValue = value;
          },
        ),
        actions: [
          OutlinedButton(
            child: const Text('确认'),
            onPressed: () {
              isOk = true;

              Navigator.pop(context);
            },
          ),
          OutlinedButton(
            child: const Text('取消'),
            onPressed: () {
              isOk = false;

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );

  if (isOk && inputValue != null) {
    return inputValue!;
  } else {
    return null;
  }
}
