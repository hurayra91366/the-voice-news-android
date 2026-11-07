class AppConfig {
  static const String siteUrl = 'https://thevoice.news';
  static const String apiUrl = '$siteUrl/wp-json/wp/v2';
  static const String englishUrl = siteUrl;
  static const String banglaUrl = '$siteUrl/bn/';
  // Set your official live/video URLs before publishing.
  static const String youtubeChannelUrl = '';
  static const String youtubeLiveUrl = '';
  static const String privacyPolicyUrl = '';
  // WordPress appears to expose Polylang (pll/v1). Confirm that REST
  // query parameter `lang=en` / `lang=bn` filters posts on your site.
  static const String enCode = 'en';
  static const String bnCode = 'bn';
}
