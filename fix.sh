#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/magisk

TOKEN=$(grep -oE 'ghp_[A-Za-z0-9]{20,}' /storage/emulated/0/MT2/密码.txt | head -1)
[ -z "$TOKEN" ] && { echo "✗ token 为空"; exit 1; }

MIRROR="https://ghfast.top/"
BASE="https://raw.githubusercontent.com/topjohnwu/Magisk/v31.0/app/apk/src"

echo "═══════════════════════════════════════"
echo "  Manifest 完全重做"
echo "═══════════════════════════════════════"
echo ""

# ═══ 1. 下载官方 manifest 覆盖本地 ═══
echo "▶ [1/4] 下载官方 manifest"
for v in main release; do
    printf "  %-8s ... " "$v"
    if curl -fL -sS -o "app/apk/src/$v/AndroidManifest.xml" \
         "${MIRROR}${BASE}/$v/AndroidManifest.xml" 2>/dev/null; then
        echo "✓ 加速镜像"
    elif curl -fL -sS -o "app/apk/src/$v/AndroidManifest.xml" \
         "${BASE}/$v/AndroidManifest.xml" 2>/dev/null; then
        echo "✓ 直连"
    else
        rm -f "app/apk/src/$v/AndroidManifest.xml"
        echo "✗ 下载失败"
    fi
done
echo ""

# ═══ 2. Python 精确插入 ═══
echo "▶ [2/4] Python 精确插入权限 + service"
command -v python3 >/dev/null 2>&1 || pkg install -y python

python3 << 'PYEOF'
import re, os

def fix(path):
    if not os.path.exists(path):
        print(f"  ⊘ {path} 不存在")
        return

    with open(path) as f:
        c = f.read()

    # 清理所有旧的 uses-permission 和 MusicService（防止残留）
    c = re.sub(r'^\s*<uses-permission[^>]*/?>\s*\n', '', c, flags=re.MULTILINE)
    c = re.sub(r'^\s*<service[^>]*MusicService[^>]*/?>\s*\n', '', c, flags=re.MULTILINE)

    # 权限块
    perms = (
        '    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />\n'
        '    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />\n'
        '    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />\n'
        '    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />\n\n'
    )

    # service 块
    svc = (
        '        <service\n'
        '            android:name=".ui.music.MusicService"\n'
        '            android:foregroundServiceType="mediaPlayback"\n'
        '            android:exported="false" />\n\n'
    )

    # 在 <application 前插权限
    c, n1 = re.subn(r'(\s*<application\b)', '\n' + perms + r'\1', c, count=1)

    # 在 </application> 前插 service
    c, n2 = re.subn(r'(\s*</application>)', '\n' + svc + r'\1', c, count=1)

    with open(path, 'w') as f:
        f.write(c)

    print(f"  ✓ {path}  (权限={n1}, service={n2})")

fix("app/apk/src/main/AndroidManifest.xml")
fix("app/apk/src/release/AndroidManifest.xml")
PYEOF
echo ""

# ═══ 3. 显示结果 ═══
echo "▶ [3/4] 修复结果"
echo "  ─── main 前 15 行 ───"
head -15 app/apk/src/main/AndroidManifest.xml | sed 's/^/    /'
echo ""
echo "  ─── main 尾部 ───"
tail -10 app/apk/src/main/AndroidManifest.xml | sed 's/^/    /'
echo ""
echo "  ─── release 全文 ───"
cat app/apk/src/release/AndroidManifest.xml 2>/dev/null | sed 's/^/    /' || echo "    （无）"
echo ""

# ═══ 4. 推送并等待 ═══
echo "▶ [4/4] 推送 + 编译"
git add -A
git -c user.name="541889964" -c user.email="541889964@users.noreply.github.com" \
    commit -m "rebuild: manifest 完全重做" 2>/dev/null || echo "  （无改动）"

git config --global http.postBuffer 524288000
git config --global http.sslVerify false

git push -f "https://541889964:${TOKEN}@github.com/541889964/magisk-fork.git" main
echo "  ✓ 已推送"
echo ""

echo "  等 25 秒让 Actions 触发 ..."
sleep 25

RUN_ID=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/541889964/magisk-fork/actions/runs?per_page=1" \
  | grep -oE '"id": ?[0-9]+' | head -1 | grep -oE '[0-9]+')

echo "  Run ID: $RUN_ID"
echo "  日志: https://github.com/541889964/magisk-fork/actions/runs/$RUN_ID"
echo ""

STATUS="queued"; CONC=""
for i in $(seq 1 360); do
    INFO=$(curl -s -H "Authorization: token $TOKEN" \
      "https://api.github.com/repos/541889964/magisk-fork/actions/runs/$RUN_ID")
    STATUS=$(echo "$INFO" | grep -oE '"status": ?"[^"]+"' | head -1 | cut -d'"' -f4)
    CONC=$(echo "$INFO" | grep -oE '"conclusion": ?"[^"]+"' | head -1 | cut -d'"' -f4)
    printf "\r  状态: %-12s 结论: %-12s [%4ds]" "$STATUS" "${CONC:-—}" "$((i*5))"
    [ "$STATUS" = "completed" ] && break
    sleep 5
done
echo ""
echo ""

if [ "$CONC" = "success" ]; then
    echo "═══════════════════════════════════════"
    echo "  ✓ 编译成功"
    echo "═══════════════════════════════════════"
    echo ""
    echo "APK 下载（加速）："
    echo "  https://ghfast.top/https://github.com/541889964/magisk-fork/releases"
else
    echo "═══════════════════════════════════════"
    echo "  ✗ 编译失败"
    echo "═══════════════════════════════════════"
    echo ""
    echo "  日志: https://github.com/541889964/magisk-fork/actions/runs/$RUN_ID"
    echo ""
    echo "  ⚠ 请把红色步骤的错误截图发我"
fi
