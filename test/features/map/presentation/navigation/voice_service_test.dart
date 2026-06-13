import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/presentation/navigation/step_tracker.dart';
import 'package:hospital_app/features/map/presentation/navigation/voice_service.dart';

void main() {
  group('VoiceCueDecider', () {
    test('announces an upcoming turn within lead distance, once', () {
      final decider = VoiceCueDecider();
      final approaching = _state(
        currentStep: const RouteStep(
          location: 1,
          maneuver: StepManeuver.straight,
          distance: 0,
        ),
        nextStep: const RouteStep(
          location: 4,
          maneuver: StepManeuver.left,
          distance: 1,
        ),
        nextStepIndex: 2,
        distance: kCueThresholdCells - 0.01,
      );

      expect(
        decider.decide(state: approaching, muted: false)?.voiceKey,
        'turn_left',
      );
      // Still approaching the same turn → silent (no repeat, no "go straight").
      expect(decider.decide(state: approaching, muted: false), isNull);
    });

    test(
      'announces go straight for the current segment when no turn is near',
      () {
        final decider = VoiceCueDecider();
        final cruising = _state(
          currentStep: const RouteStep(
            location: 1,
            maneuver: StepManeuver.straight,
            distance: 0,
          ),
          nextStep: const RouteStep(
            location: 9,
            maneuver: StepManeuver.left,
            distance: 1,
          ),
          nextStepIndex: 5,
          distance: kCueThresholdCells + 2,
        );

        expect(
          decider.decide(state: cruising, muted: false)?.voiceKey,
          'go_straight',
        );
        // Same segment → not repeated.
        expect(decider.decide(state: cruising, muted: false), isNull);
      },
    );

    test('mute suppresses without marking the step spoken', () {
      final decider = VoiceCueDecider();
      final state = _state(
        nextStep: const RouteStep(
          location: 10,
          maneuver: StepManeuver.right,
          distance: 1,
        ),
        nextStepIndex: 4,
        distance: 1,
      );

      expect(decider.decide(state: state, muted: true), isNull);
      expect(decider.decide(state: state, muted: false), isNotNull);
    });

    test('never announces arrived (spoken separately at the destination)', () {
      final decider = VoiceCueDecider();
      const arrive = RouteStep(
        location: 9,
        maneuver: StepManeuver.arrive,
        distance: 0,
      );
      final state = _state(
        currentStep: arrive,
        nextStep: arrive,
        nextStepIndex: 5,
        distance: 0,
      );

      expect(decider.decide(state: state, muted: false), isNull);
    });
  });

  group('voice key resolution', () {
    test('prefers online voiceText', () {
      const step = RouteStep(
        location: 1,
        maneuver: StepManeuver.left,
        voiceText: 'turn_right',
        distance: 0,
      );

      expect(resolveVoiceKey(step), 'turn_right');
    });

    test('falls back to offline maneuver', () {
      const step = RouteStep(
        location: 1,
        maneuver: StepManeuver.right,
        distance: 0,
      );

      expect(resolveVoiceKey(step), 'turn_right');
    });
  });

  group('bundled voice assets', () {
    test('knows the committed Vietnamese clip keys', () {
      expect(bundledVoiceKeys, {
        'turn_left',
        'turn_right',
        'go_straight',
        'arrived',
        'elevator_up',
        'elevator_down',
        'stairs_up',
        'stairs_down',
      });
    });

    test('resolves asset paths without the assets prefix', () {
      expect(voiceAssetPath('turn_left'), 'voice/vi/turn_left.mp3');
    });
  });

  group('CuePlayer', () {
    test('plays bundled asset before TTS when available', () async {
      final clipPlayer = _FakeClipPlayer();
      final tts = _FakeTtsSpeaker();
      final player = CuePlayer(tts: tts, clipPlayer: clipPlayer);

      await player.play(
        const VoiceCue(key: 'k', voiceKey: 'turn_right', fallbackText: null),
      );

      expect(clipPlayer.playedAssets, ['voice/vi/turn_right.mp3']);
      expect(tts.spoken, isEmpty);
    });

    test('swallows asset AbortError without TTS fallback', () async {
      final clipPlayer = _FakeClipPlayer()
        ..assetError = Exception(
          'AbortError: The play() request was interrupted by a call to pause()',
        );
      final tts = _FakeTtsSpeaker();
      final player = CuePlayer(tts: tts, clipPlayer: clipPlayer);

      await player.play(
        const VoiceCue(key: 'k', voiceKey: 'turn_left', fallbackText: null),
      );

      expect(clipPlayer.playedAssets, ['voice/vi/turn_left.mp3']);
      expect(tts.spoken, isEmpty);
    });

    test('falls back to built-in Vietnamese text on asset failure', () async {
      final clipPlayer = _FakeClipPlayer()..assetError = Exception('format');
      final tts = _FakeTtsSpeaker();
      final player = CuePlayer(tts: tts, clipPlayer: clipPlayer);

      await player.play(
        const VoiceCue(key: 'k', voiceKey: 'turn_left', fallbackText: null),
      );

      expect(clipPlayer.playedAssets, ['voice/vi/turn_left.mp3']);
      expect(tts.spoken, ['Rẽ trái']);
    });

    test('falls back to instruction for an unknown unbundled key', () async {
      final tts = _FakeTtsSpeaker();
      final player = CuePlayer(tts: tts, clipPlayer: _FakeClipPlayer());

      await player.play(
        const VoiceCue(key: 'k', voiceKey: 'unknown', fallbackText: 'Fallback'),
      );

      expect(tts.spoken, ['Fallback']);
    });

    test('falls back to instruction when no voice key exists', () async {
      final tts = _FakeTtsSpeaker();
      final player = CuePlayer(tts: tts, clipPlayer: _FakeClipPlayer());

      await player.play(
        const VoiceCue(
          key: 'k',
          voiceKey: null,
          fallbackText: 'Take the stairs',
        ),
      );

      expect(tts.spoken, ['Take the stairs']);
    });

    test('stays silent when no key or instruction exists', () async {
      final clipPlayer = _FakeClipPlayer();
      final tts = _FakeTtsSpeaker();
      final player = CuePlayer(tts: tts, clipPlayer: clipPlayer);

      await player.play(
        const VoiceCue(key: 'k', voiceKey: null, fallbackText: null),
      );

      expect(clipPlayer.playedAssets, isEmpty);
      expect(tts.spoken, isEmpty);
    });

    test('speakArrived plays the bundled arrival asset', () async {
      final clipPlayer = _FakeClipPlayer();
      final service = VoiceService(
        player: CuePlayer(tts: _FakeTtsSpeaker(), clipPlayer: clipPlayer),
      );

      await service.speakArrived(muted: false);

      expect(clipPlayer.playedAssets, ['voice/vi/arrived.mp3']);
    });

    test('serializes overlapping asset cues without stopping first', () async {
      final firstAsset = Completer<void>();
      final secondAsset = Completer<void>();
      final clipPlayer = _FakeClipPlayer()
        ..assetPlayFutures.addAll([firstAsset.future, secondAsset.future]);
      final player = CuePlayer(tts: _FakeTtsSpeaker(), clipPlayer: clipPlayer);

      final first = player.play(
        const VoiceCue(key: 'first', voiceKey: 'turn_left', fallbackText: null),
      );
      await Future<void>.delayed(Duration.zero);
      final second = player.play(
        const VoiceCue(
          key: 'second',
          voiceKey: 'turn_right',
          fallbackText: null,
        ),
      );

      expect(clipPlayer.playedAssets, ['voice/vi/turn_left.mp3']);
      expect(clipPlayer.stopCount, 0);

      firstAsset.complete();
      await Future<void>.delayed(Duration.zero);

      expect(clipPlayer.playedAssets, [
        'voice/vi/turn_left.mp3',
        'voice/vi/turn_right.mp3',
      ]);
      expect(clipPlayer.stopCount, 0);

      secondAsset.complete();
      await Future.wait([first, second]);
    });

    test('plays cues sequentially without overlapping', () async {
      final firstAsset = Completer<void>();
      final clipPlayer = _FakeClipPlayer()
        ..assetPlayFutures.add(firstAsset.future);
      final player = CuePlayer(tts: _FakeTtsSpeaker(), clipPlayer: clipPlayer);

      final a = player.play(
        const VoiceCue(key: 'a', voiceKey: 'turn_left', fallbackText: null),
      );
      final b = player.play(
        const VoiceCue(key: 'b', voiceKey: 'go_straight', fallbackText: null),
      );
      final c = player.play(
        const VoiceCue(key: 'c', voiceKey: 'turn_right', fallbackText: null),
      );
      await Future<void>.delayed(Duration.zero);

      // The first clip is still playing; the rest wait behind it (no overlap).
      expect(clipPlayer.playedAssets, ['voice/vi/turn_left.mp3']);

      firstAsset.complete();
      await Future.wait([a, b, c]);

      expect(clipPlayer.playedAssets, [
        'voice/vi/turn_left.mp3',
        'voice/vi/go_straight.mp3',
        'voice/vi/turn_right.mp3',
      ]);
    });
  });
}

StepTrackingState _state({
  required RouteStep nextStep,
  required int nextStepIndex,
  required double distance,
  RouteStep currentStep = const RouteStep(
    location: 0,
    maneuver: StepManeuver.start,
    distance: 0,
  ),
}) {
  return StepTrackingState(
    currentStep: currentStep,
    nextStep: nextStep,
    currentStepIndex: 0,
    nextStepIndex: nextStepIndex,
    distanceToNextStep: distance,
  );
}

class _FakeTtsSpeaker implements TtsSpeaker {
  final spoken = <String>[];
  var stopCount = 0;

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }
}

class _FakeClipPlayer implements LocalClipPlayer {
  final playedAssets = <String>[];
  final assetPlayFutures = <Future<void>>[];
  var stopCount = 0;
  var disposed = false;
  var unlockCount = 0;
  Object? assetError;

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
    final error = assetError;
    if (error != null) {
      throw error;
    }
    if (assetPlayFutures.isNotEmpty) {
      await assetPlayFutures.removeAt(0);
    }
  }

  @override
  Future<void> unlockForWeb() async {
    unlockCount++;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}
