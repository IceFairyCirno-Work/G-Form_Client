# G-Form

A cross-platform Flutter client for creating, editing, and managing **Google Forms** on mobile and desktop. Sign in with Google, browse your forms, build from templates, edit questions, review responses, and export data — all outside the browser.

**Current version:** `0.9.0+1`

## Features

- **Google Sign-In** — OAuth 2.0 with scoped access to Forms, Drive, Sheets, and Apps Script
- **Form library** — Grid and list views, search, sort, ownership filters, and infinite scroll
- **Template gallery** — Start from curated templates across community, education, health, and work categories
- **Form editor** — Four tabs: Edit, Preview, Responses, and Settings
- **Rich question types** — Multiple choice, checkbox, short answer, paragraph, dropdown, linear scale, date, time, image, video, grids, sections, and info blocks
- **Response management** — Summary and per-question views; export to **XLSX** or **CSV**
- **Extended form settings** — Email collection, response limits, confirmation messages, and more via Google Apps Script (settings the REST API does not expose)
- **Localization** — English, Japanese, Chinese (Simplified & Traditional), Portuguese, Indonesian, Russian, German, and French
- **Responsive UI** — Material 3 design that adapts to phones, tablets, and desktop window sizes
- **Connectivity awareness** — Offline state detection with graceful degradation

## Supported platforms

| Platform | Status |
|----------|--------|
| Android  | Supported |
| iOS      | Supported |
| Web      | Supported |
| Windows  | Supported |
| macOS    | Supported |
| Linux    | Supported |

## Screenshots

> Add screenshots here after your first release build.

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.12+** (Dart `^3.12.0`)
- A [Google Cloud project](https://console.cloud.google.com/) with the following APIs enabled:
  - Google Forms API
  - Google Drive API
  - Google Sheets API
  - Apps Script API *(optional, for extended form settings)*
- OAuth 2.0 credentials (Web client ID for `serverClientId`, plus platform-specific client IDs)

### 1. Clone and install dependencies

```bash
git clone https://github.com/IceFairyCirno/work.git
cd G-Form/googleform_client
flutter pub get
```

### 2. Configure environment variables

Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

| Variable | Description |
|----------|-------------|
| `GOOGLE_SERVER_CLIENT_ID` | Web OAuth client ID (used as `serverClientId` on mobile) |
| `GOOGLE_APPS_SCRIPT_ID` | Deployment ID for `FormSettingsManager` *(optional)* |
| `GOOGLE_SCOPE_*` | OAuth scopes — defaults in `.env.example` are usually fine |
| `GOOGLE_*_API_URL` | API base URLs — defaults in `.env.example` are usually fine |

### 3. Set up Google Sign-In per platform

#### Android

1. Create an **Android** OAuth client in Google Cloud Console using your app's package name and SHA-1 fingerprint.
2. Add the **Web client ID** to `.env` as `GOOGLE_SERVER_CLIENT_ID`.

#### iOS

1. Download `GoogleService-Info.plist` from Firebase / Google Cloud and place it at `ios/Runner/GoogleService-Info.plist`.
2. Set `GIDClientID` and the reversed client ID URL scheme in `ios/Runner/Info.plist` to match your iOS OAuth client.

#### Web / Desktop

Follow the [google_sign_in](https://pub.dev/packages/google_sign_in) package docs for your target platform.

### 4. Run the app

```bash
flutter run
```

Pick a device when prompted, or target a specific platform:

```bash
flutter run -d chrome      # Web
flutter run -d windows       # Windows
flutter run -d macos         # macOS
```

## Google Apps Script setup (optional)

Some form settings (accepting responses, shuffle questions, edit-after-submit, etc.) are not available through the Google Forms REST API. G-Form applies them via an Apps Script deployment.

1. Open [script.google.com](https://script.google.com) and create a new project.
2. Paste the contents of [`googleform_client/scripts/FormSettingsManager.gs`](googleform_client/scripts/FormSettingsManager.gs).
3. Deploy as **API executable**, executing as **Me**.
4. Copy the **Script ID** into `.env` as `GOOGLE_APPS_SCRIPT_ID`.

Without this step, core form editing still works; only the extended Settings tab features are limited.

## Project structure

```
G-Form/
└── googleform_client/          # Flutter application
    ├── lib/
    │   ├── main.dart             # App entry point
    │   ├── models/               # Form, question, and response models
    │   ├── screens/              # Login, home, editor, settings
    │   ├── services/             # Auth, Forms API, Apps Script, connectivity
    │   ├── widgets/              # Shared UI components
    │   ├── utils/                # Templates, responsive layout, icons
    │   └── l10n/                 # Localization ARB files
    ├── scripts/
    │   └── FormSettingsManager.gs
    ├── tools/                    # Locale generation scripts
    └── .env.example
```

## Localization

Translations live in `googleform_client/lib/l10n/*.arb`. After editing ARB files, regenerate localizations:

```bash
cd googleform_client
flutter gen-l10n
```

Supported locales: `en`, `ja`, `zh`, `zh_Hant`, `pt`, `id`, `ru`, `de`, `fr`.

## Development

```bash
cd googleform_client

flutter analyze          # Static analysis
flutter test             # Run tests
flutter build apk        # Android release build
flutter build ios        # iOS release build
```

## Tech stack

- **Flutter** + **Material 3**
- [`google_sign_in`](https://pub.dev/packages/google_sign_in) — Authentication
- [`http`](https://pub.dev/packages/http) — Google REST APIs
- [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) — Environment config
- [`excel`](https://pub.dev/packages/excel) — XLSX export
- [`webview_flutter`](https://pub.dev/packages/webview_flutter) — In-app form preview
- [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) — Network status
Please do **not** commit `.env`, `GoogleService-Info.plist`, or other credential files.
