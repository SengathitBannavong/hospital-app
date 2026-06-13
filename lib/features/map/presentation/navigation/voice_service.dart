import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/presentation/navigation/step_tracker.dart';

// How many grid blocks before a turn the cue fires. Higher = earlier warning.
const double kCueThresholdCells = 6;

const Set<String> bundledVoiceKeys = {
  'turn_left',
  'turn_right',
  'go_straight',
  'arrived',
  'elevator_up',
  'elevator_down',
  'stairs_up',
  'stairs_down',
};

@visibleForTesting
String voiceAssetPath(String key) => 'voice/vi/$key.mp3';

class VoiceCue {
  final String key;
  final String? voiceKey;
  final String? fallbackText;

  const VoiceCue({
    required this.key,
    required this.voiceKey,
    required this.fallbackText,
  });
}

class VoiceCueDecider {
  String? _lastSpokenKey;

  VoiceCue? decide({required StepTrackingState state, required bool muted}) {
    if (muted) {
      return null;
    }

    // 1) An upcoming turn within the lead distance takes priority. Announce it
    //    once; while still approaching the same turn, stay silent so we don't
    //    also say "go straight" right before turning. (Arrival is spoken once
    //    by speakArrived, so it's never announced here.)
    final turn = state.nextStep;
    final turnKey = turn == null ? null : resolveVoiceKey(turn);
    if (turn != null &&
        turnKey != null &&
        turnKey != 'arrived' &&
        state.distanceToNextStep < kCueThresholdCells) {
      if (turnKey == _lastSpokenKey) {
        return null;
      }
      return _take(turn, turnKey);
    }

    // 2) Otherwise announce the segment we're on when its key changes — e.g.
    //    "go straight" once we've finished a turn and there's no turn nearby.
    final current = state.currentStep;
    final currentKey = current == null ? null : resolveVoiceKey(current);
    if (current != null &&
        currentKey != null &&
        currentKey != 'arrived' &&
        currentKey != _lastSpokenKey) {
      return _take(current, currentKey);
    }

    return null;
  }

  VoiceCue _take(RouteStep step, String voiceKey) {
    _lastSpokenKey = voiceKey;
    return VoiceCue(
      key: voiceKey,
      voiceKey: voiceKey,
      fallbackText: step.instruction,
    );
  }

  void reset() {
    _lastSpokenKey = null;
  }
}

@visibleForTesting
String? resolveVoiceKey(RouteStep step) {
  return step.voiceText ?? maneuverToVoiceKey(step.maneuver);
}

@visibleForTesting
String? maneuverToVoiceKey(StepManeuver maneuver) {
  return switch (maneuver) {
    StepManeuver.left => 'turn_left',
    StepManeuver.right => 'turn_right',
    StepManeuver.straight || StepManeuver.start => 'go_straight',
    StepManeuver.arrive => 'arrived',
    StepManeuver.floorChange => null,
    StepManeuver.uTurn => null,
  };
}

@visibleForTesting
String? builtInVoiceText(String key) {
  return switch (key) {
    'go_straight' => 'Đi thẳng',
    'turn_left' => 'Rẽ trái',
    'turn_right' => 'Rẽ phải',
    'arrived' => 'Đã đến đích',
    'elevator_up' => 'Đi thang máy lên',
    'elevator_down' => 'Đi thang máy xuống',
    'stairs_up' => 'Đi cầu thang lên',
    'stairs_down' => 'Đi cầu thang xuống',
    _ => null,
  };
}

abstract class TtsSpeaker {
  Future<void> speak(String text);
  Future<void> stop();
}

class FlutterTtsSpeaker implements TtsSpeaker {
  final FlutterTts _tts;

  FlutterTtsSpeaker({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.awaitSpeakCompletion(false);
    unawaited(_tts.setLanguage('vi-VN'));
    // Ambient honors the iOS silent switch.
    if (!kIsWeb) {
      unawaited(
        _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          const <IosTextToSpeechAudioCategoryOptions>[],
        ),
      );
    }
  }

  @override
  Future<void> speak(String text) async {
    await stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}

abstract class LocalClipPlayer {
  Future<void> playAsset(String assetPath);
  Future<void> unlockForWeb();
  Future<void> stop();
  Future<void> dispose();
}

final AudioContext _kVoiceAudioContext = AudioContext(
  android: const AudioContextAndroid(
    // Use the media stream (the volume the user actually turns up) so cues are
    // reliably audible; the navigation-guidance stream is near-silent on many
    // devices. Still duck other audio briefly.
    contentType: AndroidContentType.speech,
    usageType: AndroidUsageType.media,
    audioFocus: AndroidAudioFocus.gainTransientMayDuck,
  ),
  iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
);

class AudioPlayersClipPlayer implements LocalClipPlayer {
  // One pre-warmed player per clip, keyed by asset path. Each holds its decoded
  // clip in memory (ReleaseMode.stop keeps the source loaded), so playing is an
  // instant seek+resume instead of a 2–3s load on first use.
  final Map<String, AudioPlayer> _players;
  AudioPlayer? _active;

  AudioPlayersClipPlayer({Map<String, AudioPlayer>? players})
    : _players = players ?? _buildPool();

  static Map<String, AudioPlayer> _buildPool() {
    final pool = <String, AudioPlayer>{};
    for (final key in bundledVoiceKeys) {
      final path = voiceAssetPath(key);
      final player = AudioPlayer();
      pool[path] = player;
      unawaited(_preload(player, path));
    }
    return pool;
  }

  static Future<void> _preload(AudioPlayer player, String assetPath) async {
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setAudioContext(_kVoiceAudioContext);
      await player.setVolume(1);
      // Load the clip into memory now so the first cue plays immediately.
      await player.setSource(AssetSource(assetPath));
    } catch (error) {
      debugPrint('[voice] preload failed $assetPath: $error');
    }
  }

  @override
  Future<void> playAsset(String assetPath) async {
    final player = _players[assetPath];
    if (player == null) {
      // Not a preloaded clip — let the caller fall back to TTS.
      throw StateError('No preloaded voice clip for $assetPath');
    }
    // Sequential queue means the previous clip already finished, but if a
    // different player is somehow still active, stop it first.
    final previous = _active;
    if (previous != null && !identical(previous, player)) {
      await previous.stop();
    }
    _active = player;

    final completed = player.onPlayerComplete.first.then<void>((_) {});
    await player.seek(Duration.zero);
    await player.resume();
    // Return only when the clip finishes so queued cues never overlap. Bounded
    // by the clip's own length (+ buffer) via a plain delay race — NOT
    // Future.timeout(onTimeout:), whose callback typing breaks on web's DDC
    // runtime — so a missed completion event can't stall the queue.
    final duration = await player.getDuration();
    final cap =
        (duration ?? const Duration(seconds: 3)) +
        const Duration(milliseconds: 300);
    await Future.any<void>([completed, Future<void>.delayed(cap)]);
  }

  @override
  Future<void> unlockForWeb() async {
    if (!kIsWeb) {
      return;
    }
    // Satisfy the browser autoplay gesture with a preloaded player at volume 0.
    final player = _players[voiceAssetPath('go_straight')];
    if (player == null) {
      return;
    }
    try {
      await player.setVolume(0);
      await player.seek(Duration.zero);
      await player.resume();
      await player.stop();
      await player.setVolume(1);
    } catch (error) {
      if (!_isAbortError(error)) {
        debugPrint('[voice] web unlock failed: $error');
        return;
      }
      debugPrint('[voice] web unlock interrupted');
    }
  }

  @override
  Future<void> stop() async {
    await _active?.stop();
  }

  @override
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
  }
}

class CuePlayer {
  final TtsSpeaker _tts;
  final LocalClipPlayer _clipPlayer;
  Future<void> _tail = Future<void>.value();
  // Bumped on every stop() so cues already queued before the stop are dropped
  // instead of playing afterwards (e.g. when navigation is cancelled).
  int _generation = 0;

  CuePlayer({TtsSpeaker? tts, LocalClipPlayer? clipPlayer})
    : _tts = tts ?? FlutterTtsSpeaker(),
      _clipPlayer = clipPlayer ?? AudioPlayersClipPlayer();

  // Queue cues so they play sequentially and never talk over each other. Each
  // link is bounded by the clip length (see playAsset), so the chain can't
  // stall. Cues are deduped per turn upstream, so the queue stays short.
  Future<void> play(VoiceCue cue) {
    final generation = _generation;
    final next = _tail.then((_) {
      // A stop() between queueing and playing invalidates this cue.
      if (generation != _generation) return Future<void>.value();
      return _playNow(cue);
    });
    _tail = next.catchError((_) {});
    return next;
  }

  Future<void> _playNow(VoiceCue cue) async {
    final key = cue.voiceKey;
    if (key == null) {
      await _speakIfPresent(cue.fallbackText);
      return;
    }

    if (bundledVoiceKeys.contains(key)) {
      await _tts.stop();
      try {
        await _clipPlayer.playAsset(voiceAssetPath(key));
        return;
      } catch (error) {
        if (_isAbortError(error)) {
          debugPrint('[voice] asset clip interrupted key=$key');
          return;
        }
        debugPrint('[voice] asset clip failed key=$key: $error');
      }
    }

    if (await _speakIfPresent(builtInVoiceText(key))) {
      return;
    }
    await _speakIfPresent(cue.fallbackText);
  }

  Future<bool> _speakIfPresent(String? text) async {
    if (text == null || text.trim().isEmpty) {
      return false;
    }
    await _clipPlayer.stop();
    await _tts.speak(text);
    return true;
  }

  Future<void> stop() async {
    // Drop any cue still waiting in the queue, then halt what's playing now.
    _generation++;
    await Future.wait([_clipPlayer.stop(), _tts.stop()]);
  }

  Future<void> unlockForStartGesture() async {
    await _clipPlayer.unlockForWeb();
    await _tts.speak('');
  }

  Future<void> dispose() async {
    await stop();
    await _clipPlayer.dispose();
  }
}

bool _isAbortError(Object error) {
  final message = error.toString();
  return message.contains('AbortError') ||
      message.contains('interrupted by a call to pause') ||
      message.contains('interrupted by a call to stop');
}

class VoiceService {
  final CuePlayer _player;
  final VoiceCueDecider _decider;

  VoiceService({CuePlayer? player, VoiceCueDecider? decider})
    : _player = player ?? CuePlayer(),
      _decider = decider ?? VoiceCueDecider();

  Future<VoiceCue?> speakFor({
    required StepTrackingState state,
    required bool muted,
  }) async {
    final cue = _decider.decide(state: state, muted: muted);
    if (cue == null) {
      if (muted) {
        await _player.stop();
      }
      return null;
    }
    await _player.play(cue);
    return cue;
  }

  Future<void> speakArrived({required bool muted}) async {
    if (muted) {
      await _player.stop();
      return;
    }
    await _player.play(
      const VoiceCue(key: 'arrived', voiceKey: 'arrived', fallbackText: null),
    );
  }

  Future<void> pauseSpeaking() {
    return _player.stop();
  }

  Future<void> unlockForStartGesture() {
    return _player.unlockForStartGesture();
  }

  Future<void> reset() async {
    _decider.reset();
    await _player.stop();
  }

  Future<void> dispose() async {
    _decider.reset();
    await _player.dispose();
  }
}
