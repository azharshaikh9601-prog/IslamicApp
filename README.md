# Hafiz Hasnain Jaani - Official Islamic Application

A comprehensive, production-ready Islamic mobile and desktop platform featuring a **Flutter** client and a **.NET 10** REST API backend powered by **Entity Framework Core**.

---

## 🏗️ Architecture

```
IslamicApp/
├── .github/
│   └── workflows/
│       └── build-apk.yml       # Automated GitHub Action to build Android APK on push
├── flutter_app/                # Flutter frontend (Windows Desktop & Android)
│   ├── android/                # Android native platform files
│   ├── windows/                # Windows native desktop runner
│   ├── lib/
│   │   ├── core/               # Theme, colors, utilities
│   │   ├── models/             # Video, Reel, Playlist, Course, Quote, Dhikr models
│   │   ├── services/           # API service (HTTP client) & storage cache
│   │   ├── screens/            # Home, Shorts, Lessons, Courses, Quotes, Admin
│   │   └── widgets/            # In-app players, Salah schedule, Tasbeeh counter
│   └── pubspec.yaml
├── IslamicApp.Api/             # .NET 10 Web API Backend
│   ├── Data/                   # EF Core DbContext, migrations & SQL database service
│   ├── Migrations/             # Official Entity Framework Core migrations
│   ├── Models/                 # DTOs and database entity models
│   ├── Program.cs              # Minimal API endpoints & DI configuration
│   └── appsettings.json
└── IslamicApp.sln              # Visual Studio Solution file
```

---

## 🚀 Running the Application

### 1. Backend (.NET 10 API)
You can open `IslamicApp.sln` directly in **Visual Studio 2022 / 2026** and press **F5**, or run:
```powershell
cd IslamicApp.Api
dotnet run
```
The API starts on `http://localhost:5000`.

### 2. Frontend (Flutter Windows Desktop)
```powershell
cd flutter_app
flutter run -d windows
```

### 3. Automated Android APK Build (GitHub Actions)
Whenever code is pushed to `main`, `master`, or `dev`, GitHub Actions triggers `.github/workflows/build-apk.yml`:
- Compiles the Flutter project
- Produces a release APK: `app-release.apk`
- Uploads the APK to the **GitHub Actions Artifacts** for direct download

---

## 🌟 Key Features
- **Salah Timetable**: Real-time prayer countdown and Hanafi/Shafi'i calculations across 24 global/district locations.
- **YouTube Bayanaat & Lessons**: Dual-column playlists and categorized video masterclasses.
- **In-App Vertical Shorts**: Fast scrolling 9:16 reels with persistent likes, view tracking, and in-app playback.
- **Daily Hadith & Quotes**: Golden sayings in Arabic, Urdu, and English with admin posting capabilities.
- **Interactive Tasbeeh Counter**: Digital beads counter with haptic feedback and global counter tally.
- **Admin Management**: Dedicated portal to manage courses, upload bayans, post quotes, and answer Ummah inquiries.
