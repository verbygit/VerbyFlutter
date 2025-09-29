import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;

  /// Play thank you sound based on current locale
  /// English: thankyou.mp3
  /// German: thankyouGernman.mp3
  static Future<void> playThankYouSound(BuildContext context) async {
    try {
      // Don't play if already playing to avoid overlapping sounds
      if (_isPlaying) return;

      _isPlaying = true;
      
      // Get current locale to determine which sound file to play
      final currentLocale = EasyLocalization.of(context)?.locale;
      final soundFile = _getSoundFileForLocale(currentLocale);
      
      await _audioPlayer.play(AssetSource('sound/$soundFile'));
      
      // Reset playing state after sound duration (approximately 2-3 seconds)
      await Future.delayed(const Duration(seconds: 3), () {
        _isPlaying = false;
      });
      
    } catch (e) {
      print('Error playing sound: $e');
      _isPlaying = false;
    }
  }

  /// Get the appropriate sound file based on locale
  static String _getSoundFileForLocale(Locale? locale) {
    if (locale != null) {
      switch (locale.languageCode.toLowerCase()) {
        case 'de':
          return 'thankyouGernman.mp3';
        case 'en':
        default:
          return 'thankyou.mp3';
      }
    }
    return 'thankyou.mp3'; // Default to English
  }

  /// Stop current sound if playing
  static Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isPlaying = false;
    } catch (e) {
      print('Error disposing sound service: $e');
    }
  }
}
