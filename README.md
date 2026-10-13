# Castaway: Survival Island (iOS)

A native iPhone and iPad app that runs the Castaway game fully offline in a full-screen web view.

```
Castaway.xcodeproj         Open this in Xcode
Castaway/
  AppDelegate.swift        Audio session setup
  SceneDelegate.swift      Window; pauses and saves the game when you leave the app
  GameViewController.swift Full-screen landscape web view, haptics bridge
  BundleSchemeHandler.swift Serves the Game folder at castaway://localhost
  Game/                    The game itself: index.html, three.js, fonts (all bundled, no internet needed)
  Assets.xcassets          App icon, launch screen color
  Info.plist               Landscape only, full screen, no encryption
AppStore/                  Listing text, screenshots, privacy and support pages
tools/build_game.py        Rebuilds Game/index.html from a new web version of the game
web/castaway-island.html   The web version of the game (the source for Game/index.html)
```

## Put it on your iPhone

1. Open `Castaway.xcodeproj` in Xcode (15 or newer).
2. Click the **Castaway** project in the left sidebar → **Castaway** target → **Signing & Capabilities**.
3. Pick your **Team**. If Xcode says the bundle ID is taken, change `com.wolfhope.castaway` to something like `com.wolfhope.castawaysurvival`.
4. Plug in your iPhone (or pick it from the device menu at the top), then press **Run** (⌘R).
5. The first time, your phone may ask you to trust the developer: Settings → General → VPN & Device Management.

Tip: use a Release build to judge speed. Debug builds run the game just as fast (the game is JavaScript), but if anything feels slow, try Product → Scheme → Edit Scheme → Run → Build Configuration → Release.

## Send it to the App Store

1. In App Store Connect, create a new app with the same bundle ID. Name, subtitle, description, keywords and review notes are in `AppStore/listing.md`.
2. Upload the screenshots in `AppStore/screenshots/` (6.9" iPhone and 13" iPad).
3. Put `AppStore/website/privacy.html` and `support.html` on your WolfhopeCom.github.io site (in a `castaway` folder), and replace `SUPPORT_EMAIL` in support.html with your email.
4. In Xcode, choose **Any iOS Device (arm64)**, then **Product → Archive** → **Distribute App** → **App Store Connect**.
5. Back in App Store Connect, pick the build, answer the age-rating and privacy questions (see listing.md), and submit.

## Updating the game later

When the web version of the game changes, replace `web/castaway-island.html` and run:

```
python3 tools/build_game.py web/castaway-island.html
```

That rewrites `Castaway/Game/index.html` with the CDN links swapped for the bundled copies. Then bump the **Build** number in Xcode (target → General) and archive again.

## Debugging

In Debug builds the web view can be inspected from Safari on a Mac: Safari → Settings → Advanced → Show features for web developers, then Develop → your iPhone → Castaway. JavaScript errors from the game show up in that console.

## Credits

three.js (MIT), Barlow and IM Fell English fonts (SIL Open Font License). Licenses are in `Castaway/Game/lib` and `Castaway/Game/fonts`.
