import 'dart:async';

class RestTimer {
  Timer? timer;

  void start(int seconds, Function(int) onTick, Function() onDone) {
    int remaining = seconds;

    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;

      onTick(remaining);

      if (remaining <= 0) {
        t.cancel();
        onDone();
      }
    });
  }

  void stop() {
    timer?.cancel();
  }
}
