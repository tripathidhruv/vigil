<div align="center">

# 🚨 VIGIL
### *Always Watching. Always Ready.*

**The unified crisis command platform for hotels — AI-driven situation assessment, real-time staff coordination, multilingual guest safety, and post-crisis analytics in one place.**

[![Live Demo](https://img.shields.io/badge/🌐_Live_Demo-vigil--three--kohl.vercel.app-FF3B3B?style=for-the-badge)](https://vigil-three-kohl.vercel.app)
[![Download APK](https://img.shields.io/badge/📱_Download_APK-v1.0-4CAF50?style=for-the-badge)](https://github.com/tripathidhruv/vigil/releases/tag/v1.0)
[![Google Solution Challenge](https://img.shields.io/badge/🏆_Google_Solution_Challenge-2026-4285F4?style=for-the-badge)](https://developers.google.com/community/gdsc-solution-challenge)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-4285F4?style=flat&logo=google&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)

</div>

---

## 📌 The Problem

A 2024 Deloitte report found that **63% of hotel executives** see crisis preparedness as key to guest loyalty — yet most properties rely on fragmented tools spread across departments. When a fire breaks out, a gas leak is reported, or a medical emergency strikes, staff are left scrambling across WhatsApp groups, walkie-talkies, and paper checklists.

**VIGIL eliminates that entirely: one platform, zero silos, sub-60-second activation.**

---

## 💡 What is VIGIL?

VIGIL is an **AI-powered crisis intelligence platform** built specifically for the hospitality industry. It helps hotel staff detect, respond to, and document emergencies faster and more effectively — while keeping guests informed in their own language.

From the moment a crisis is reported to the final compliance report, VIGIL handles the entire response chain automatically.

---

## ✨ Core Features

### 🧠 AI Situation Commander
Staff describes the crisis in plain language (e.g. *"Gas leak near kitchen, floor 3"*). Gemini AI classifies the crisis type, severity, and affected zones in under 3 seconds and auto-generates a step-by-step response playbook tailored to the hotel's layout and real-time occupancy.

### 👥 Dynamic Role Assignment Engine
Reads the current shift roster from real-time check-in data and auto-assigns crisis roles instantly — no manual delegation under panic. Each assigned staff member receives an FCM push notification with their specific task and escalation chain.

### 🌐 Multilingual Guest Alert System
Pulls guest nationality from booking profiles and fires crisis instructions in their native language via push notification and in-app message. Gemini handles tone-calibrated translation — urgent, clear, not robotic — across **50+ languages**.

### 🏛️ Live Collaborative War Room
A shared real-time incident feed where every department head posts live status updates. Every action is timestamped and visible chain-wide. Auto-compiles into a structured post-crisis report the moment the incident is marked resolved.

### 🎯 Drill & Simulation Mode
Gemini generates randomized, realistic crisis scenarios for staff training drills. Tracks response speed and decision quality across all roles. Produces a staff readiness score and surfaces weak links in the response chain — before a real emergency hits.

### 📋 Compliance Auto-Reporter
After every incident, Gemini drafts a formal compliance report in the regulatory format required by local hospitality bodies. Pulls data from the war room log, timestamps, and role assignments. Exports as PDF or Google Doc.

### 📡 IoT Sensor & Floor Map Integration *(New)*
Integrates with smart smoke detectors, temperature sensors, and access control via MQTT or Firebase IoT bridge. Plots triggered sensors on an interactive floor map, giving commanders a real-time spatial view of crisis spread.

### 🚑 Emergency Services Auto-Dispatch *(New)*
On crisis confirmation above a severity threshold, VIGIL auto-drafts a structured emergency brief and routes it to the hotel's linked emergency contacts — fire, medical, or police — via SMS and email.

### 📊 Manager Command Dashboard *(New)*
A web-based dashboard showing live crisis status, staff deployment map, readiness scores per team, historical incident trends, and drill completion rates. The single-pane-of-glass for senior leadership during and after any crisis.

---

## 🛠️ Tech Stack

| Category | Technology | Plan |
|----------|-----------|------|
| **AI & Intelligence** | Gemini API | Free tier |
| | Vertex AI | $300 credit |
| | Google Translate API | Free quota |
| | Natural Language API | Free quota |
| **Backend & Database** | Firebase Firestore | Spark plan |
| | Firebase Realtime Database | Spark plan |
| | Firebase Auth | Free |
| | Firebase Cloud Messaging | Free |
| | BigQuery | Free tier |
| **Frontend & Platform** | Flutter (iOS + Android) | Free |
| | Flutter Web (Dashboard) | Free |
| | Google Maps API | Free quota |
| | Looker Studio | Free |
| **Communications** | Twilio SMS | Free trial |
| | SendGrid Email | Free tier |
| | Google Docs API | Free |
| | Google Sheets API | Free |

> ✅ **100% Free Tier** — No credit card required for submission or demo.

---

## 🎯 UN SDG Alignment

| SDG | Goal | How VIGIL Helps |
|-----|------|----------------|
| **3** | Good Health & Well-being | Faster emergency response reduces injury and mortality. Multilingual alerts ensure no guest is left without safety info due to a language barrier. |
| **11** | Sustainable Cities & Communities | Hotels are critical urban infrastructure. VIGIL strengthens hospitality resilience, especially in high-tourism areas where a crisis can affect hundreds of international visitors. |
| **16** | Peace, Justice & Strong Institutions | Auto-generated compliance reports create an auditable record of every crisis response — supporting regulatory accountability and reducing post-incident legal ambiguity. |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- Firebase project with Firestore, Auth, and FCM enabled
- Gemini API key (free at [aistudio.google.com](https://aistudio.google.com))

### Installation

```bash
# Clone the repository
git clone https://github.com/tripathidhruv/vigil.git
cd vigil

# Install dependencies
flutter pub get

# Run on Android/iOS
flutter run

# Run on Web
flutter run -d chrome
```

### Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Firestore**, **Realtime Database**, **Authentication**, and **FCM**
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the respective `android/app/` and `ios/Runner/` directories

### Environment Variables
Create a `.env` file in the root directory:
```
GEMINI_API_KEY=your_gemini_api_key_here
GOOGLE_MAPS_API_KEY=your_maps_api_key_here
```

---

## 📱 Try It Now

| Platform | Link |
|----------|------|
| 🌐 **Web App (Live Demo)** | [vigil-three-kohl.vercel.app](https://vigil-three-kohl.vercel.app) |
| 📱 **Android APK** | [Download from Releases](https://github.com/tripathidhruv/vigil/releases/tag/v1.0) |

**To install the APK on Android:**
1. Download `app-release.apk` from the Releases page
2. On your phone: Settings → Security → Allow unknown sources
3. Open the downloaded file and tap Install

---

## 🗂️ Project Structure

```
vigil/
├── lib/
│   ├── main.dart               # App entry point
│   ├── screens/                # UI screens
│   ├── services/               # Firebase & Gemini services
│   ├── models/                 # Data models
│   └── widgets/                # Reusable UI components
├── android/                    # Android-specific files
├── ios/                        # iOS-specific files
├── web/                        # Flutter Web build
├── assets/                     # Images, icons, fonts
└── pubspec.yaml                # Dependencies
```

---

## 🏗️ Build Phases

| Phase | Focus | Timeline |
|-------|-------|----------|
| 1 | Foundation & Infrastructure (Flutter + Firebase + Auth) | Week 1–2 |
| 2 | Crisis Engine & AI Commander (Gemini integration) | Week 3–4 |
| 3 | Guest Comms, Dispatch & Drills | Week 5–7 |
| 4 | Analytics, Compliance & Reporting | Week 7–8 |
| 5 | Polish, Testing & Demo Prep | Week 9–10 |

---

## 👥 Team

Built for the **Google Solution Challenge 2026** — Rapid Crisis Response Track.

| Role | Focus |
|------|-------|
| Dev 1 | Flutter UI + UX |
| Dev 2 | Firebase Backend |
| Dev 3 | Gemini AI Integration |
| Dev 4 | Demo Video + Docs + IoT |

---

## 📄 License

This project is submitted as part of the Google Solution Challenge 2026. All rights reserved.

---

<div align="center">

**VIGIL** — *Always Watching. Always Ready.*

Made with ❤️ for the Google Solution Challenge 2026

</div>
