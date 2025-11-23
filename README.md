# Offline Chat System

A Flutter mobile chat app with offline-first capabilities. Messages are saved locally and automatically sync with the Node.js backend when online.

## 📱 Screenshots

![Chat Screen](screenshots/chat_rooom.jpeg)
![Sync Status](screenshots/online_sync.jpg)
![Offline Mode](screenshots/offline.jpg)

## ✨ Key Features

- **Offline-First**: Send messages without internet - they sync automatically when online
- **Auto Sync**: Triggered on message send, network change, or manual sync button
- **Status Indicators**: 🕐 Clock = pending sync | ✓✓ = synced to server
- **WhatsApp-Style UI**: Modern gradient bubbles and clean design
- **Local Storage**: Hive database keeps all messages accessible offline

## 🏗️ How It Works

1. **Send Message** → Saved to Hive (local DB) with `isSynced: false`
2. **App Attempts Sync** → Sends unsynced messages to backend
3. **Server Receives** → Stores in JSON file, marks `isSynced: true`
4. **Conflict Resolution** → Last-Write-Wins (newest timestamp wins)
5. **Client Updates** → Marks messages as synced, shows ✓✓ icon

```
Flutter App (Hive) ←→ HTTP API ←→ Node.js Server (db.json)
     Offline            Sync          Always On
```

## 📦 Tech Stack

**Frontend (Flutter)**
- `hive` & `hive_flutter` - Local NoSQL database
- `http` - API requests
- `connectivity_plus` - Network monitoring
- `uuid` - Unique message IDs
- `intl` - Date formatting

**Backend (Node.js)**
- `express` - Web server
- `cors` - Cross-origin requests
- JSON file storage

## 🚀 Quick Start

### 1. Start Backend
```bash
cd backend
npm install
node server.js
# Server runs on http://localhost:3000
```

### 2. Run Flutter App
```bash
cd chat_flutter
flutter pub get
flutter run
```

### 3. Configure API URL
In `lib/services/api_service.dart`:
```dart
// iOS Simulator
static const String base = "http://localhost:3000";

// Android Emulator
// static const String base = "http://10.0.2.2:3000";

// Physical Device (use your Mac's IP)
// static const String base = "http://192.168.x.x:3000";
```

## 🔧 Important Files

- `backend/server.js` - Express API with `/sync` endpoint
- `chat_flutter/lib/screens/chat_screen.dart` - Main UI
- `chat_flutter/lib/services/sync_service.dart` - Sync logic
- `chat_flutter/lib/hive/hive_manager.dart` - Local storage

## 📡 API

**POST /sync**
```json
Request: { "localMessages": [...], "lastSyncTime": "ISO-8601" }
Response: { "success": true, "serverMessages": [...] }
```

## 🧪 Test Offline Mode

**iOS Simulator**: Settings → Developer → Network Link Conditioner → 100% Loss

**Android Emulator**: Extended Controls (...) → Settings → Cellular → None

## 💡 Tips

- Open `ios/Runner.xcworkspace` (not .xcodeproj) when using Xcode
- For physical devices, change bundle ID in `project.pbxproj`
- Ensure both devices on same WiFi network

---

**Built with Flutter & Node.js**
