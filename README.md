# ★ XPNS TRACKER ★
### Maximalist Mixed-Media Expense Tracker · Flutter · Android & iOS

---

## 🎨 Design Philosophy
Inspired by prettycoolstrangers.com — brutalist, maximalist, mixed-media art aesthetic.
Bold typography (Bebas Neue), thick offset box-shadows, sticker tags, ticker tape, star bursts, grainy textures, high-contrast color blocks.

---

## 📱 SCREENS
1. **Dashboard** — Net worth, monthly stats, AI insight card, recent transactions
2. **Add Transaction** — Number pad, category picker, account selector (<5 sec entry)
3. **Accounts** — Bank / Credit Card / UPI / Cash cards with live balances
4. **Analytics** — Pie chart (category split), bar chart (daily spend), month comparison
5. **Budgets** — Monthly limits, progress bars, 80%/100% alert badges
6. **Transactions** — Full searchable/filterable history with swipe-to-delete
7. **Categories** — Create/edit/delete with icon + color picker, subcategories

---

## 🛠️ SETUP INSTRUCTIONS

### Prerequisites
- Flutter SDK 3.16+ → https://docs.flutter.dev/get-started/install
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 26+)

### Step 1 — Get the fonts
Download these free fonts and place in `assets/fonts/`:
- **Bebas Neue** → https://fonts.google.com/specimen/Bebas+Neue
  - Save as: `BebasNeue-Regular.ttf`
- **Space Mono** → https://fonts.google.com/specimen/Space+Mono
  - Save as: `SpaceMono-Regular.ttf`, `SpaceMono-Bold.ttf`, `SpaceMono-Italic.ttf`, `SpaceMono-BoldItalic.ttf`

### Step 2 — Install dependencies
```bash
cd xpns_app
flutter pub get
```

### Step 3 — Run on Android
```bash
# Connect your phone (enable USB debugging) or start an emulator
flutter run
```

### Step 4 — Build release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Step 5 — Build AAB (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 💳 CREDIT CARD LOGIC (Non-Negotiable Rules)
| Action | Effect |
|--------|--------|
| Spend on CC | Increases `outstanding_due`, does NOT reduce bank balance |
| Pay CC bill | Reduces bank balance + reduces `outstanding_due` (use Transfer) |
| Transfer between accounts | Net worth stays the same |

---

## 🏗️ ARCHITECTURE
```
lib/
├── main.dart               # App entry, Hive init, seed data, shell + nav
├── models/
│   ├── models.dart         # Account, Category, Transaction, Budget + enums
│   └── models.g.dart       # Hive type adapters
├── providers/
│   └── providers.dart      # Riverpod providers + TransactionService
├── screens/
│   ├── dashboard_screen.dart
│   ├── add_transaction_screen.dart
│   ├── accounts_screen.dart
│   ├── analytics_screen.dart
│   ├── budgets_screen.dart
│   ├── transactions_screen.dart
│   ├── categories_screen.dart
│   └── settings_screen.dart
├── theme/
│   └── app_theme.dart      # Colors, text styles, BoxDecoration helpers
└── widgets/
    └── shared_widgets.dart # TickerTape, StickerTag, StatCard, BrutalButton, etc.
```

---

## 📦 KEY DEPENDENCIES
| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `hive_flutter` | Local offline database |
| `fl_chart` | Pie + bar charts |
| `google_fonts` | Typography fallback |
| `firebase_core` + `cloud_firestore` | Cloud sync (optional) |
| `local_auth` | Biometric lock |
| `flutter_local_notifications` | Budget alerts |
| `uuid` | ID generation |

---

## 🔥 FIREBASE SETUP (optional for cloud sync)
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package `com.xpns.tracker`
3. Download `google-services.json` → place in `android/app/`
4. Enable Authentication (Google Sign-In) + Firestore

---

## 🎨 COLOR PALETTE
| Name | Hex |
|------|-----|
| Yellow | `#FFE600` |
| Red | `#E8230A` |
| Blue | `#1B3FFF` |
| Pink | `#FF3CAC` |
| Green | `#00C46A` |
| Black | `#0D0D0D` |
| Paper | `#EDE8DC` |

---

## ✅ TEST CASES
- [ ] Expense → account balance decreases
- [ ] Income → account balance increases
- [ ] Transfer → net worth unchanged
- [ ] CC expense → outstanding_due increases, bank balance unchanged
- [ ] CC payment (transfer to CC) → bank decreases, due decreases
- [ ] Budget at 80% → ALMOST FULL badge appears
- [ ] Budget at 100%+ → OVER BUDGET badge appears in red

---

*Built with Flutter · Designed in the maximalist mixed-media art tradition*
*★ TRACK EVERY RUPEE ★*
