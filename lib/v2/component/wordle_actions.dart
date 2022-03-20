import 'package:flutter/material.dart';

class WordleActions extends StatelessWidget {
  const WordleActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {},
          child: const Text("确认"),
        ),
        OutlinedButton(
          onPressed: () {},
          child: const Text("设置"),
        ),
        OutlinedButton(
          onPressed: () {},
          child: const Text("删除"),
        )
      ],
    );
  }
}
