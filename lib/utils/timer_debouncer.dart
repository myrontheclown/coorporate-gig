import 'dart:async';

/// Debounces callbacks so they only run after [duration] has passed without a
/// new invocation (used for map-searching / reverse-geocoding).
class TimerDebouncer {
  final Duration duration;
  Timer? _timer;

  TimerDebouncer({required this.duration});

  /// Schedules [action], cancelling any pending run.
  void run(void Function() action) {
    cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}