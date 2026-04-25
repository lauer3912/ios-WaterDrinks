# WaterDrinks - App Store Pre-Submission Checklist

## ✅ Project Files Complete

| Item | Status | Notes |
|------|--------|-------|
| project.yml | ✅ | CODE_SIGNING_ALLOWED: NO(Debug)/YES(Release) |
| Info.plist | ✅ | ITSAppUsesNonExemptEncryption: false |
| Entitlements (App) | ✅ | App Groups: group.com.ggsheng.WaterDrinks |
| Entitlements (Widget) | ✅ | App Groups: group.com.ggsheng.WaterDrinks |
| AppIcon Contents.json | ✅ | 19 entries, all correct |
| AccentColor | ✅ | Blue theme |
| Assets.xcassets | ✅ | Complete |

## ✅ Code Quality

| Item | Status | Notes |
|------|--------|-------|
| CJK Scan | ✅ | Zero Chinese characters |
| English Only | ✅ | All UI text in English |
| Permissions | ✅ | NSUserNotificationsUsageDescription only |
| Bundle ID | ✅ | com.ggsheng.WaterDrinks |

## ✅ App Store Assets

| Item | Status | Notes |
|------|--------|-------|
| Listing.md | ✅ | App Store description prepared |
| Privacy Policy | ✅ | AppStore/docs/PrivacyPolicy.html |
| Screenshots | ⏳ | Need to generate on MacinCloud |

## ⚠️ Pending Items (MacinCloud)

### 1. Generate XcodeGen Project
```bash
cd ~/Desktop/ios-WaterDrinks
~/tools/xcodegen/bin/xcodegen generate
```

### 2. Generate Screenshots (9 minimum)
- iPhone 6.9" (16 Pro Max): 1290×2796 × 3
- iPhone 6.7" (15/16): 1170×2556 × 3
- iPad 12.9": 2048×2732 × 3

### 3. Build & Archive
```bash
xcodebuild -project WaterDrinks.xcodeproj \
  -scheme WaterDrinks \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive
```

### 4. Upload via Transporter
```bash
xcrun altool --upload-package WaterDrinks.xcarchive \
  --type iOS \
  --apiKey PP57R568AX \
  --apiIssuer b2a00f88-3a8d-40d0-b148-1f1db92e10b7
```

### 5. Create App Store Connect Entry
- Name: WaterDrinks
- Category: Health & Fitness
- Age Rating: 4+
- Privacy Policy URL: https://lauer3912.github.io/ios-WaterDrinks/docs/PrivacyPolicy.html

## 📁 File Structure
```
ios-WaterDrinks/
├── AppStore/
│   ├── Listing.md          ✅
│   └── docs/
│       └── PrivacyPolicy.html ✅
├── WaterDrinks/
│   ├── App/                ✅ (WaterDrinksApp, ContentView, ThemeManager)
│   ├── Models/             ✅ (WaterEntry)
│   ├── ViewModels/         ✅ (WaterViewModel)
│   ├── Views/              ✅ (5 views)
│   ├── Assets.xcassets/   ✅ (AppIcon 19 entries)
│   ├── Info.plist          ✅
│   └── WaterDrinks.entitlements ✅
├── WaterDrinksWidget/      ✅
├── WaterDrinksTests/       ✅
├── WaterDrinksUITests/     ✅
└── project.yml             ✅
```

## Git Status
- Remote: https://github.com/lauer3912/ios-WaterDrinks
- Last Push: April 25, 2026