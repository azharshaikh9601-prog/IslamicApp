# Hafiz Hasnain Jaani - Official Flutter Mobile Application

A cross-platform mobile application built with Flutter & Dart for Islamic Scholar & YouTuber **Hafiz Hasnain Jaani** (`@HAFIZHASNAINJAANI`), mirroring every feature from the official web application with native performance.

---

## 📱 Features Included

1. **Islamic Stories Carousel**:
   - Animated glowing gold rings (Tahajjud, Namaz 101, Wudu Sunnat, Baghdadi Qaida, Sajda Mistake, Daily Hadith).
   - Fullscreen popover with Arabic calligraphy and Urdu/English guidance.

2. **YouTube Bayan Library**:
   - Instant search across lectures, Fiqh, and Masail.
   - Category filtering (`All Topics`, `Masterclasses`, `Namaz Ka Tarika`, `Wudu & Ghusl`, `Baghdadi Qaida`, `Masail & Fiqh`, `Naats & Duas`).
   - High-res YouTube thumbnail cards with duration badges, bookmark persistence, and 1-click WhatsApp sharing.

3. **Islamic Shorts / Reels Feed (Vertical 9:16)**:
   - Fullscreen vertical scrolling feed mimicking TikTok / Instagram Reels.
   - Interactive Like button with counter, WhatsApp sharing with prefilled text, and open in YouTube Shorts.

4. **Deen Suite & Utilities**:
   - **Digital Tasbeeh Counter**: Responsive clickable bead counter with realistic vibration haptics, circular progress bar, reset button, and preset Dhikr selection (`Subhan'Allah`, `Alhamdulillah`, `Allahu Akbar`, `Astaghfirullah`, `Durood Sharif`, `Kalima Tawheed`).
   - **Astronomical Solar Prayer Times Engine**: Lifelong mathematical accuracy for Fajr, Sunrise, Dhuhr, Asr, Maghrib, and Isha. Built-in index of Indian states and districts (Purnia HQ, Bareilly Sharif, Delhi, Mumbai, Patna, Katihar, Kishanganj, Lucknow, Ajmer Sharif, etc.) and world cities, with Hanafi & Shafi'i Asr calculation switcher.
   - **Ask a Mas'ala (Fatwa Inquiries)**: Direct WhatsApp submission form connecting users directly to Hafiz Hasnain Jaani's office.

5. **Daily Quotes & Social Media Poster Studio**:
   - Curated Ayahs and Sahih Hadiths with Arabic calligraphy, Urdu translation, and English context.
   - 1-Click WhatsApp Status Card generator with official branding.

6. **Executive Scholar Dashboard**:
   - Real-time KPI metrics (411K+ Subscribers, active bayans, shorts views).
   - Live app broadcast announcement manager to push messages across the entire app.
   - Content distribution visual analytics.
   - WhatsApp fatwa inquiries management.

---

## 🚀 How to Run the Flutter Project

### 1. Install Flutter SDK
If you haven't installed Flutter yet:
1. Download Flutter from [flutter.dev](https://docs.flutter.dev/get-started/install/windows).
2. Extract to `C:\src\flutter` and add `C:\src\flutter\bin` to your environment PATH.
3. Verify by running:
   ```bash
   flutter doctor
   ```

### 2. Fetch Dependencies
Navigate to the `flutter_app` folder:
```bash
cd flutter_app
flutter pub get
```

### 3. Run Locally (Android / iOS / Web / Windows)
```bash
flutter run
```

---

## 📦 Building Production APK / AAB for Google Play Store

To generate a release build ready for the Google Play Store:

```bash
flutter build appbundle --release
```
The output file will be generated at:
`build/app/outputs/bundle/release/app-release.aab`
