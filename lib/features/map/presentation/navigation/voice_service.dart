import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:hospital_app/features/map/presentation/navigation/maneuver_text.dart';
import 'package:hospital_app/features/map/presentation/navigation/step_tracker.dart';

class VoiceCue {
  final String key;
  final String text;

  const VoiceCue({required this.key, required this.text});
}

class VoiceCueDecider {
  String? _lastSpokenKey;

  VoiceCue? decide({
    required StepTrackingState state,
    required bool muted,
  }) {
    if (muted) {
      return null;
    }
    final step = state.nextStep ?? state.currentStep;
    if (step == null) {
      return null;
    }

    final stepIndex = state.nextStepIndex ?? state.currentStepIndex;
    final key = '$stepIndex:${step.location}:${step.maneuver.name}';
    if (_lastSpokenKey == key) {
      return null;
    }

    final cue = VoiceCue(
      key: key,
      text: spokenManeuverText(step, state.distanceToNextStep),
    );
    _lastSpokenKey = key;
    return cue;
  }

  void reset() {
    _lastSpokenKey = null;
  }
}

abstract class TtsSpeaker {
  Future<void> speak(String text);
  Future<void> stop();
}

class FlutterTtsSpeaker implements TtsSpeaker {
  final FlutterTts _tts;

  FlutterTtsSpeaker({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.awaitSpeakCompletion(false);
    // Ambient honors the iOS silent switch; Android focus stays default false.
    unawaited(
      _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        const <IosTextToSpeechAudioCategoryOptions>[],
      ),
    );
  }

  @override
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}

class VoiceService {
  final TtsSpeaker _speaker;
  final VoiceCueDecider _decider;

  VoiceService({
    TtsSpeaker? speaker,
    VoiceCueDecider? decider,
  }) : _speaker = speaker ?? FlutterTtsSpeaker(),
       _decider = decider ?? VoiceCueDecider();

  Future<VoiceCue?> speakFor({
    required StepTrackingState state,
    required bool muted,
  }) async {
    final cue = _decider.decide(state: state, muted: muted);
    if (cue == null) {
      if (muted) {
        await _speaker.stop();
      }
      return null;
    }
    await _speaker.speak(cue.text);
    return cue;
  }

  Future<void> reset() async {
    _decider.reset();
    await _speaker.stop();
  }
}
