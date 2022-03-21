import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wordle/v2/component/wordle_display_row.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/util/util.dart';

import '../util/event_bus.dart';

enum DisplayStatus { statusFull, statusShortcut }

class DisplayModel extends ChangeNotifier {
  late DisplayStatus _displayStatus;

  DisplayModel.full() : _displayStatus = DisplayStatus.statusFull;

  DisplayModel.shortcut() : _displayStatus = DisplayStatus.statusShortcut;

  set displayStatus(DisplayStatus status) {
    if (status != _displayStatus) {
      _displayStatus = status;
      notifyListeners();
    }
  }

  DisplayStatus get displayStatus {
    return _displayStatus;
  }

  DisplayModel copyWith({
    DisplayStatus? displayStatus,
  }) {
    return DisplayModel(
      displayStatus: displayStatus ?? _displayStatus,
    );
  }

  DisplayModel({
    required DisplayStatus displayStatus,
  }) : _displayStatus = displayStatus;
}

class WordleDisplay extends StatefulWidget {
  const WordleDisplay({Key? key}) : super(key: key);

  @override
  State<WordleDisplay> createState() => _WordleDisplayState();
}

class _WordleDisplayState extends State<WordleDisplay> {
  late ScreenshotController _controller;
  late EventCallback _callback;
  late EventBus _bus;
  late DisplayModel _displayModel;

  @override
  void initState() {
    super.initState();

    _controller = ScreenshotController();
    _displayModel = DisplayModel.full();

    _bus = context.read<EventBus>();

    _callback = (_) {
      setState(() {
        _displayModel.displayStatus = DisplayStatus.statusShortcut;

        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _controller.capture().then((img) async {
            if (img != null) {
              if (await Permission.storage.request().isGranted) {
                final directory = await getApplicationDocumentsDirectory();
                final imagePath =
                    await File('${directory.path}/screenshot.png').create();
                await imagePath.writeAsBytes(img);

                await Share.shareFiles([imagePath.path]);

                _displayModel.displayStatus = DisplayStatus.statusFull;
              } else {
                Fluttertoast.showToast(msg: "需要存储访问权限以分享截图");

                openAppSettings();
              }
            }
          });
        });
      });
    };

    _bus.register('screenshot', _callback);
  }

  @override
  void dispose() {
    super.dispose();

    _bus.unregister("screenshot", _callback);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, int>(
      selector: (context, model) => model.inputLogs.length,
      builder: (context, len, child) {
        return Screenshot(
          controller: _controller,
          child: ChangeNotifierProvider.value(
            value: _displayModel,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: len
                    .rangeUntil(from: 0)
                    .map(
                      (e) => Expanded(
                        child: WordleDisplayRow(
                          rowIndex: e,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
