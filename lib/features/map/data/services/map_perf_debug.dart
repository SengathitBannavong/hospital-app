// TEMP DEBUG INSTRUMENTATION — delete this file and every `perfLog(` call site
// when done. Single-grep cleanup: grep -rn "perfLog\|map_perf_debug" lib/
import 'package:flutter/foundation.dart';

/// Monotonic clock shared by all perf probes so log lines share one timeline.
/// The leading `+Nms` is elapsed time since the first probe fired.
final Stopwatch _perfClock = Stopwatch()..start();

void perfLog(String message) {
  debugPrint('[DBG-perf +${_perfClock.elapsedMilliseconds}ms] $message');
}
