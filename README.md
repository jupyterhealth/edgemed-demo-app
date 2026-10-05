# Domain / deep link support

How to add a new host for invitation deep links.

## 1. Host the well-known files on the new domain

Serve these at the domain root (HTTPS, no redirects):

- `https://<domain>/.well-known/apple-app-site-association`
- `https://<domain>/.well-known/assetlinks.json`

Canonical copies live in [`well-known/`](well-known/). Copy them as-is unless package names or signing certs change.

### `apple-app-site-association` (iOS)

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

### `assetlinks.json` (Android)

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

## 2. App changes

| File | What to add |
|------|-------------|
| [`lib/utils/invitation_utils.dart`](lib/utils/invitation_utils.dart) | host in `InvitationLink.hosts` |
| [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) | `<data android:scheme="https" android:host="..." android:pathPrefix="/clients/ucsf-edge" />` |
| [`ios/Runner/Runner.entitlements`](ios/Runner/Runner.entitlements) | `applinks:<domain>` under associated-domains |

That’s it.
