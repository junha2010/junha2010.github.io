# Bible Android

This is a small Android WebView wrapper for the hosted Bible website at `https://junha2010.github.io/bible/`.

## Open in Android Studio

1. Open Android Studio.
2. Choose **Open**.
3. Select this folder:

```text
D:\GitHub\junha2010.github.io\bible-android
```

4. Let Gradle sync.
5. Select the `app` run configuration and press Run.

If Android Studio asks for an SDK, install Android 11.0 / API 30. If it asks for a Gradle JDK, use Java 8 or Java 11 for this project.

## Build APK From PowerShell

```powershell
.\build-apk.ps1
```

The APK is written to:

```text
dist\BibleViewer-debug.apk
```
