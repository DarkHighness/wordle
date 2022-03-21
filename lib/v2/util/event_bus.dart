typedef EventCallback = void Function(dynamic);

class EventBus {
  final _map = <Object, List<EventCallback>?>{};

  void register(event, EventCallback callback) {
    _map[event] ??= <EventCallback>[];
    _map[event]!.add(callback);
  }

  void unregister(event, [EventCallback? callback]) {
    var list = _map[event];

    if (event == null || list == null) {
      return;
    }

    if (callback == null) {
      _map[event] = null;
    } else {
      list.remove(callback);
    }
  }

  void emit(event, [args]) {
    var list = _map[event];

    if (list == null) {
      return;
    }

    int len = list.length - 1;

    for (var i = len; i > -1; --i) {
      list[i](args);
    }
  }
}
