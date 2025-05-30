/// Helper for mapping app locales to speech-to-text locale IDs.
class SpeechLocaleHelper {
  static String getSpeechLocaleId(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'ur_PK';
      case 'hi':
        return 'hi_IN';
      case 'ar':
        return 'ar_SA';
      case 'en':
      default:
        return 'en_US';
    }
  }
}
