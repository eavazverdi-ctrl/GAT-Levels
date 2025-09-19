CLOUD BUILD (no installs needed on your PC)

1) Make a new empty GitHub repo.
2) Upload *all* files from this folder (keep the same structure).
3) Go to the repo's "Actions" tab → run "Build Android APK".
4) Wait a few minutes → open the workflow run → download the artifact "fx_levels-apk".
5) The file `app-release.apk` is your installable APK.

Notes:
- If you want a debug APK instead, change `flutter build apk --release` to `--debug` in .github/workflows/build-apk.yml.
