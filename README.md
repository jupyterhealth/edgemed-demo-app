# EdgeMed patient app

A Flutter app for iOS and Android that lets a patient share wearable health data with a study on a [JupyterHealth Exchange](https://github.com/jupyterhealth/jupyterhealth-exchange) (JHE) server.

A patient opens an invitation link from their study team, accepts the consent and terms, sets a passcode, and connects a wearable through [Open Wearables](https://github.com/the-commons-project/open-wearables). The app then uploads blood glucose, blood pressure, heart rate, step and sleep data to JHE and shows it on a dashboard, with an intake questionnaire sent to the study as a FHIR QuestionnaireResponse.

## Requirements

- Flutter, pinned by [`.fvmrc`](.fvmrc) and installed with [fvm](https://fvm.app) (`brew install fvm`)
- Xcode (iOS) and/or the Android SDK with Java 17+ (Android)
- CocoaPods (iOS)

## Setup

```sh
fvm install                       # installs the pinned Flutter version
cp .env.json.example .env.json    # then fill in the values
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
```

`build_runner` generates the `*.g.dart`, `*.freezed.dart`, `*.gr.dart` and DI config files, which are not committed. Re-run it after changing any annotated class or route.

### `.env.json`

The app reads its configuration at build time from `.env.json` (via `--dart-define-from-file`). The file is gitignored.

| Key | Value |
|-----|-------|
| `ENV` | `staging`, `preprod` or `prod` — must match the flavor you build |
| `API_BASE_URL` | JHE server, e.g. `https://jhe.fly.dev` |
| `OW_API_URL` | Open Wearables server |
| `SENTRY_DSN` | Sentry DSN, or leave as `change-me` to disable crash reporting |
| `TERMS_AND_CONDITIONS_URL` | Shown during onboarding |
| `PRIVACY_POLICY_URL` | Shown during onboarding |

## Flavors

Three flavors build three separately installable apps, so they can live side by side on one device:

| Flavor | Android package / iOS bundle ID |
|--------|--------------------------------|
| `staging` | `com.jupyter.health.staging` |
| `preprod` | `com.jupyter.health.preprod` |
| `prod` | `com.jupyter.health` |

## Run and build

```sh
fvm flutter run --flavor staging --dart-define-from-file .env.json
fvm flutter build apk --flavor staging --dart-define-from-file .env.json
fvm flutter build ios --flavor staging --dart-define-from-file .env.json
```

The same configurations are available in VS Code (see [`.vscode/launch.json`](.vscode/launch.json)).

### Release signing

- **iOS** signs through the Apple Developer team set in the Xcode project.
- **Android** release builds read a keystore from `~/keystores/<flavor>.keystore` and its credentials from environment variables; see `signingConfigs` in [`android/app/build.gradle.kts`](android/app/build.gradle.kts) for the variable names. Debug builds need none of this.

## Scripts

[`scripts/jhe_create_invite.py`](scripts/jhe_create_invite.py) creates a test patient and invitation on a JHE server and prints the invitation link; [`scripts/jhe_invite_existing.py`](scripts/jhe_invite_existing.py) does the same for an existing patient. Both take the practitioner password from the `JHE_PRACTITIONER_PASSWORD` environment variable and have their server, organization and study IDs at the top of the file.

## Deploying your own copy

This repository is the source of the published UCSF EdgeMed app, so it carries that app's identifiers. To ship your own build you need your own Apple Developer team and Google Play account, and you must replace everything below. None of it is secret, but none of it will work for anyone but the original app.

| What | Where |
|------|-------|
| Android package name (`com.jupyter.health`) and the `.staging` / `.preprod` suffixes | `namespace`, `applicationId` and `applicationIdSuffix` in [`android/app/build.gradle.kts`](android/app/build.gradle.kts), and the `package` line in [`android/app/src/main/kotlin/com/example/jupyter_health/MainActivity.kt`](android/app/src/main/kotlin/com/example/jupyter_health/MainActivity.kt) |
| iOS bundle IDs (`com.jupyter.health[.staging|.preprod]`) and Apple team ID | `PRODUCT_BUNDLE_IDENTIFIER` and `DEVELOPMENT_TEAM` in [`ios/Runner.xcodeproj/project.pbxproj`](ios/Runner.xcodeproj/project.pbxproj) (easiest from Xcode's Signing & Capabilities tab, once per flavor) |
| App display name | [`ios/Runner/Info.plist`](ios/Runner/Info.plist) (`CFBundleDisplayName`, `CFBundleName`) and `app_name` in `android/app/src/<flavor>/res/values/strings.xml` |
| App icon and splash screen | [`flutter_launcher_icons.yaml`](flutter_launcher_icons.yaml) and [`flutter_native_splash.yaml`](flutter_native_splash.yaml), then re-run both generators |
| Invitation deep-link hosts (your JHE and Open Wearables servers) | `InvitationLink.hosts` in [`lib/utils/invitation_utils.dart`](lib/utils/invitation_utils.dart), the `<data android:host>` entries in [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml), and `applinks:` in [`ios/Runner/Runner.entitlements`](ios/Runner/Runner.entitlements) |
| App-link verification files | Regenerate [`well-known/`](well-known/) with your bundle IDs, team ID and signing-certificate SHA-256 fingerprints, and serve them from your JHE server (see the next section). For Android, use the Play App Signing certificate fingerprint from the Play Console, not your upload key |
| FHIR source identity reported to JHE | [`lib/config/env/fhir_config.dart`](lib/config/env/fhir_config.dart): `dataSourceId` must be a DataSource that exists on your JHE server, and `fhirSourceLabel`, `fhirBaseUrl` and `questionnaireCanonical` describe your deployment |
| Android release keystores | Create your own and point `signingConfigs` in [`android/app/build.gradle.kts`](android/app/build.gradle.kts) at them |
| Server URLs, legal links, Sentry | Your own `.env.json` (see above) |

The invitation-link path prefix (`/clients/ucsf-edge`) is set in the Android manifest and in `well-known/apple-app-site-association`; keep it in sync with the path your JHE server issues.

## Domain / deep link support

How to add a new host for invitation deep links.

### 1. Host the well-known files on the new domain

Serve these at the domain root (HTTPS, no redirects):

- `https://<domain>/.well-known/apple-app-site-association`
- `https://<domain>/.well-known/assetlinks.json`

Canonical copies live in [`well-known/`](well-known/). Copy them as-is unless package names or signing certs change.

#### `apple-app-site-association` (iOS)

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": [
          "KZJSZ95597.com.jupyter.health",
          "KZJSZ95597.com.jupyter.health.staging",
          "KZJSZ95597.com.jupyter.health.preprod"
        ],
        "components": [
          {
            "/": "/clients/ucsf-edge/*",
            "comment": "UCSF Edge invitation links"
          }
        ]
      }
    ]
  }
}
```

#### `assetlinks.json` (Android)

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.jupyter.health",
      "sha256_cert_fingerprints": [
        "39:7D:A1:A1:A5:B3:26:C1:F1:5A:A5:69:D0:C6:1C:C5:67:47:11:9E:09:93:E2:A5:A5:B2:14:15:FB:07:58:47"
      ]
    }
  },
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.jupyter.health.staging",
      "sha256_cert_fingerprints": [
        "4F:98:AF:E7:A3:8E:5F:EA:47:EE:75:13:A9:BC:D7:56:1A:D4:99:D0:B8:12:22:21:65:05:AA:C2:A0:EB:86:B1"
      ]
    }
  },
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.jupyter.health.preprod",
      "sha256_cert_fingerprints": [
        "69:DB:62:B3:F3:75:8D:DC:07:EE:35:0F:D3:92:87:EA:12:D4:D2:22:8A:11:9D:16:3E:0B:BF:02:8F:4D:05:24"
      ]
    }
  }
]
```

### 2. App changes

| File | What to add |
|------|-------------|
| [`lib/utils/invitation_utils.dart`](lib/utils/invitation_utils.dart) | host in `InvitationLink.hosts` |
| [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) | `<data android:scheme="https" android:host="..." android:pathPrefix="/clients/ucsf-edge" />` |
| [`ios/Runner/Runner.entitlements`](ios/Runner/Runner.entitlements) | `applinks:<domain>` under associated-domains |

That's it.

## License

[MIT](LICENSE)
