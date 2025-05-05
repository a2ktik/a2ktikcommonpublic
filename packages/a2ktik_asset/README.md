# A2ktik asset

Public assets for a2ktik projects


## Setup

`pubspec.yaml`:

```yaml
  a2ktik_asset:
    git:
      url: https://github.com/a2ktik/a2ktikcommonpublic
      path: packages/a2ktik_asset
      ref: dart3a
```

## Usage

### Setup quick splash screen and icon in Flutter Web

`pubspec.yaml`:
```yaml
dependency:
  tekartik_web_splash:
    git:
      url: https://github.com/tekartik/app_web_utils.dart
      ref: dart3a
      path: packages/web_splash

flutter:
  assets:
    - packages/a2ktik_asset/img/a2k_icon_v1_256.png
    - packages/a2ktik_asset/img/a2k_logo_v1_640x121.png
    - packages/a2ktik_asset/js/a2k_splash.js
```

`web/index.html`:
```html
<head>
  ...
  <link rel="apple-touch-icon" href="assets/packages/a2ktik_asset/img/a2k_icon_v1_256.png">

    ...
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="assets/packages/a2ktik_asset/img/a2k_icon_v1_256.png"/>
</head>
<body>
<script src="assets/packages/a2ktik_asset/js/a2k_splash.js"></script>
<script src="flutter_bootstrap.js" async></script>
</body>
```

`manifest.json`:
```json
  ...
  "icons": [
    {
      "src": "assets/packages/a2ktik_asset/img/a2k_icon_v1_256.png",
      "sizes": "256x256",
      "type": "image/png"
    }
  ]
  ...
```

`lib/main.dart`:
```dart
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  webSplashReady();
  // optional init stuff
  ... 
  webSplashHide(); // Fadeout
  
  // Or
  // Future<void>.delayed(const Duration(milliseconds: 300))
  //    .then((_) => webSplashHide());
  runApp(...);
}
```