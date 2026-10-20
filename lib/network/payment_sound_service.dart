import 'package:audioplayers/audioplayers.dart';

class PaymentSoundService {
  // Singleton
  PaymentSoundService._internal();
  static final PaymentSoundService _instance = PaymentSoundService._internal();
  factory PaymentSoundService() => _instance;

  // State
  AudioPlayer? _player;
  bool _isPlaying = false;

  // Plays the payment-success bell sound once.
  Future<void> playPaymentSound() async {
    // Prevent duplicate / overlapping playback.
    if (_isPlaying) return;

    try {
      _isPlaying = true;

      // Lazily create the player on first use.
      _player ??= AudioPlayer();

      // Stop any residual playback from a prior invocation.
      await _player!.stop();

      // Play from the bundled asset with low-latency settings.
      await _player!.setSource(AssetSource('audio/paymentBell.wav'));
      await _player!.resume();

      // Listen for completion to reset the guard.
      _player!.onPlayerComplete.first.then((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      // Log but don't rethrow – sound failure must never block the UX.
      print('PaymentSoundService: playback error - $e');
    }
  }

  // Releases the underlying [AudioPlayer] resources.
  Future<void> dispose() async {
    try {
      await _player?.dispose();
      _player = null;
      _isPlaying = false;
    } catch (e) {
      print('PaymentSoundService: dispose error - $e');
    }
  }
}
