import 'dart:async';

import 'package:audio_waveforms/src/base/player_indentifier.dart';
import 'package:audio_waveforms/src/base/utils.dart';

///This class should be used for any type of native streams.
class PlatformStreams {
  PlatformStreams._();

  static PlatformStreams instance = PlatformStreams._();

  bool isInitialised = false;

  void init() {
    _currentDurationController =
        StreamController<PlayerIdentifier<int>>.broadcast();
    _playerStateController =
        StreamController<PlayerIdentifier<PlayerState>>.broadcast();
    isInitialised = true;
  }

  Stream<PlayerIdentifier<int>> get onDurationChanged =>
      _currentDurationController.stream;

  Stream<PlayerIdentifier<PlayerState>> get onplayerStateChanged =>
      _playerStateController.stream;

  late StreamController<PlayerIdentifier<int>> _currentDurationController;

  late StreamController<PlayerIdentifier<PlayerState>> _playerStateController;

  void addCurrentDurationEvent(PlayerIdentifier<int> playerIdentifier) {
    if (!_currentDurationController.isClosed) {
      _currentDurationController.add(playerIdentifier);
    }
  }

  void addPlayerStateEvent(PlayerIdentifier<PlayerState> playerIdentifier) {
    if (!_playerStateController.isClosed) {
      //TODO: provide a flag to stop player when playing the audio is completed
      _playerStateController.add(playerIdentifier);
    }
  }

  void dispose() async {
    await _currentDurationController.close();
    await _playerStateController.close();
    isInitialised = false;
  }
}
