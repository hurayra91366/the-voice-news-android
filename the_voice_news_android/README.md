# The Voice News — Advanced Media Android App (Flutter source v0.1)

## Included now
- Native Material 3 design with The Voice News brand colors
- English/Bangla switch, persisted locally
- WordPress REST API articles, images, pagination, category chips, search
- In-app HTML article reader, sharing, external original link
- Bookmarks with offline article text, light/dark mode
- Video and live section with configurable official YouTube URLs

## Important findings
- Website: https://thevoice.news
- Current Bengali edition is https://thevoice.news/bn/ (not /bangla/).
- WordPress REST discovery endpoint responds at https://thevoice.news/wp-json/ and lists wp/v2 and pll/v1 namespaces.
- The environment in which this source was prepared cannot run Flutter, and direct calls to individual post APIs were not verified. The app **must be tested** on a real device against both language feeds. The built-in URL-path filter guards against mixed-language articles but may need adjustment if post permalinks differ.

## Build APK locally
1. Install Flutter SDK and Android Studio; run `flutter doctor`.
2. In a terminal in this directory, run `flutter create --platforms=android .` to generate Android platform files.
3. Run `flutter pub get`.
4. Run `flutter run` with an Android device/emulator.
5. Run `flutter build apk --release` for an APK. Configure Android signing for production before distributing.
6. For Google Play, run `flutter build appbundle --release` after configuring signing, package name, icons, privacy policy, and data safety disclosures.

## Production setup required
- In `lib/core/config.dart` set official `youtubeChannelUrl`, `youtubeLiveUrl` and `privacyPolicyUrl`.
- Verify `GET /wp-json/wp/v2/posts?_embed=1&lang=en` and `...&lang=bn` plus `/categories?lang=...` work and return distinct language feeds. If site caching removes lang parameters, adjust WordPress/Polylang API caching.
- Add Firebase project, `firebase_core` and `firebase_messaging`, Android Firebase configuration, and a **trusted server-side** WordPress-to-FCM push system for editor-controlled breaking-news notifications. Push notifications are *not yet implemented* in this starter.
- For in-app YouTube video playback, implement an approved YouTube player; the starter currently opens official live/video URLs externally.
- AdMob, user accounts, personalized feeds, analytics, deep links, splash/logo assets, and editorial push dashboard are future production features, not included in this starter.
- For embedded content and complex WordPress shortcodes, consider in-app WebView fallback for articles. The current HTML viewer may not render every plugin/widget.
- WordPress content is treated as untrusted; do not store administrator credentials or API secrets in the app.
- Image URLs and HTTP endpoints should be HTTPS; API uses public read-only requests.

## File map
`lib/main.dart`: app shell, navigation, languages, feeds, search, media, bookmarks.
`lib/core`: endpoints and translations.
`lib/models`: article/category data.
`lib/services`: public WordPress feed and bookmark persistence.
`lib/screens`: feed and article reader.
`lib/widgets`: reusable article cards.

This is a first source-code deliverable, **not a precompiled APK or a tested release**.

## Build without installing Flutter locally (GitHub Actions)
1. Create a new **private** GitHub repository and upload the contents of this project folder, including `.github/workflows/build-apk.yml` (unzip locally first).
2. Open **Actions → Build Android APK → Run workflow**. The workflow also runs on pushes to `main`.
3. After the run succeeds, open the workflow run and download its `the-voice-news-android-apk` artifact. Unzip it to obtain `app-release.apk`.
4. Transfer the APK to your Android phone and install it. Android might ask you to permit installation from the source you used.

Note: The automation has not been run or validated here, because this environment has no Flutter/Android SDK and no direct access to download them. GitHub-hosted builds require internet access and a repository under your control. This build is a test/distribution APK, **not a Play Store production release**. Do not publish it to Google Play until package ID, release signing, content API, privacy disclosures and notifications are configured and tested.
