import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/component/wordle_display_row_item.dart';
import 'package:wordle/v2/util/event_bus.dart';
import 'package:wordle/v2/util/util.dart';

import '../animation/curve.dart';
import '../model/game_model.dart';

class WordleDisplayRow extends StatefulWidget {
  final int rowIndex;

  const WordleDisplayRow({Key? key, required this.rowIndex}) : super(key: key);

  @override
  State<WordleDisplayRow> createState() => _WordleDisplayRowState();
}

class _WordleDisplayRowState extends State<WordleDisplayRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _shakeAnimation;
  late EventBus _bus;
  late EventCallback _busCallback;

  bool shaking = false;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _shakeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const SineCurve(count: 4),
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.stop();

        setState(() {
          shaking = false;
        });
      }
    });

    _bus = context.read<EventBus>();

    _busCallback = (args) {
      if (args == widget.rowIndex) {
        _controller.reset();
        _controller.forward();

        setState(() {
          shaking = true;
        });
      }
    };

    _bus.register("row-shaking", _busCallback);
  }

  @override
  void dispose() {
    super.dispose();

    _bus.unregister("row-shaking", _busCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, int>(
      selector: (context, model) {
        return model.inputLogs[widget.rowIndex].length;
      },
      builder: (context, len, child) {
        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value * 12, 0),
              child: child,
            );
          },
          child: Row(
            children: len
                .rangeUntil(from: 0)
                .map(
                  (e) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: WordleDisplayRowItem(
                        rowIndex: widget.rowIndex,
                        colIndex: e,
                        shaking: shaking,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
