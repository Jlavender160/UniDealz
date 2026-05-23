# UniDealz

**iOS App | BSc Computer Science | Nottingham Trent University**
**Module:** ITEC31041 iOS Application Development | **Year:** 3rd Year (2025–2026)
**Student:** James Lavender (N1212075)

---

## Overview

UniDealz is an iOS application designed for university students to discover and share local deals near their campus. The app features an interactive map, bar crawl planner, deal carousel, reviews system, and full Firebase-backed authentication.

---

## Features

- **Deal Discovery** — Browse and favourite student deals from local venues
- **Interactive Map** — Google Maps integration showing deals and venues nearby
- **Bar Crawl Planner** — Plan and share bar crawl routes with friends
- **Reviews** — Read and write reviews for venues
- **Authentication** — Firebase Auth with email/password registration and login (with password validation)
- **Push Notifications** — Firebase Cloud Messaging integration
- **User Profiles** — Account management and liked deals history

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift 5 |
| UI Framework | SwiftUI |
| Backend | Firebase Firestore |
| Authentication | Firebase Auth |
| Maps | Google Maps SDK for iOS |
| Notifications | Firebase Cloud Messaging |
| Minimum Target | iOS 16+ |

---

## Project Structure

```
UniDealz/
├── UniDealzApp.swift          # App entry point
├── ContentView.swift          # Root navigation
├── Config.swift               # App configuration
├── AppColors.swift            # Design system colours
├── Models/
│   ├── Deal.swift             # Deal data model
│   ├── Venue.swift            # Venue data model
│   ├── Review.swift           # Review data model
│   └── UserProfile.swift      # User profile model
├── Services/
│   ├── AuthService.swift      # Firebase authentication
│   ├── FirestoreService.swift # Firestore database operations
│   ├── LocationService.swift  # Core Location wrapper
│   └── NotificationService.swift # Push notification handling
├── Views/
│   ├── Auth/                  # Login and registration screens
│   ├── HomeView.swift         # Main deals feed
│   ├── MapTabView.swift       # Interactive map view
│   ├── BarCrawlView.swift     # Bar crawl planner
│   ├── LikesView.swift        # Saved/liked deals
│   └── MoreView.swift         # Account and settings
└── Helpers/
    └── DateHelpers.swift      # Date formatting utilities
```

---

## How to Run

### Prerequisites

- Xcode 15+
- iOS 16+ device or simulator
- A Firebase project (create at [console.firebase.google.com](https://console.firebase.google.com))
- Google Maps API key

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Jlavender160/UniDealz.git
   cd UniDealz
   ```

2. Add your own `GoogleService-Info.plist` from your Firebase project into `UniDealz/` (this file is excluded from the repo for security reasons).

3. Add your Google Maps API key to `Config.swift`.

4. Open `UniDealz.xcodeproj` in Xcode and run on a simulator or device.

---

## Screenshots

*Screenshots to be added.*

---

## Author

**James Lavender** | N1212075 | Nottingham Trent University
BSc (Hons) Computer Science — 3rd Year iOS Development 2025–2026
