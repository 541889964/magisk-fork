#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/magisk

echo "▶ [1/3] 覆盖 main/AndroidManifest.xml ..."
cat > app/apk/src/main/AndroidManifest.xml <<'MAIN_EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.proteam.magisk">

    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:name=".MagiskApplication"
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.Magisk"
        android:usesCleartextTraffic="true"
        tools:ignore="UnusedAttribute">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:theme="@style/Theme.Magisk.Splash">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".ui.music.MusicService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="false" />

        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.FileProvider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>

    </application>
</manifest>
MAIN_EOF
echo "  ✓ main 已覆盖"

echo "▶ [2/3] 覆盖 release/AndroidManifest.xml ..."
cat > app/apk/src/release/AndroidManifest.xml <<'RELEASE_EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.proteam.magisk">

    <application
        android:debuggable="false"
        tools:ignore="HardcodedDebugMode" />
</manifest>
RELEASE_EOF
echo "  ✓ release 已覆盖"

echo "▶ [3/3] 推送并编译 ..."
TOKEN=$(grep -oE 'ghp_[A-Za-z0-9]{20,}' /storage/emulated/0/MT2/密码.txt | head -1)
git add -A
git -c user.name="541889964" -c user.email="541889964@users.noreply.github.com" \
    commit -m "fix: 使用完整官方 manifest 覆盖" 2>/dev/null || echo "  （无改动）"

git config --global http.postBuffer 524288000
git config --global http.sslVerify false
git push -f "https://541889964:${TOKEN}@github.com/541889964/magisk-fork.git" main
echo "  ✓ 已推送"
echo ""
echo "  等 25 秒查 Actions ..."
sleep 25
RUN_ID=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/541889964/magisk-fork/actions/runs?per_page=1" \
  | grep -oE '"id": ?[0-9]+' | head -1 | grep -oE '[0-9]+')
echo "  Run ID: $RUN_ID"
echo "  日志: https://github.com/541889964/magisk-fork/actions/runs/$RUN_ID"
