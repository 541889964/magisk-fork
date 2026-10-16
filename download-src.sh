#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Magisk 源码下载脚本（直连官方 + 子模块完整拉取）
# 用法: bash ~/magisk/download-src.sh
# ============================================================
set -e

WORK="$HOME/magisk"
UPSTREAM="https://github.com/topjohnwu/Magisk.git"
BRANCH_TAG="v31.0"

G='\033[0;32m'; Y='\033[0;33m'; R='\033[0;31m'; C='\033[0;36m'; N='\033[0m'

mkdir -p "$WORK"
cd "$WORK"

echo ""
echo -e "${C}═════════════════════════════════════════════${N}"
echo -e "${C}   Magisk 源码下载器${N}"
echo -e "${C}═════════════════════════════════════════════${N}"
echo ""

# ══════════ [1/3] 克隆主仓库 ══════════
echo -e "${C}【1/3】克隆主仓库${N}"

if [ -d ".git" ]; then
  echo -e "  ${Y}⚠${N} 检测到已有仓库，跳过克隆"
else
  # 清理可能的残留
  rm -rf "$WORK/.tmp_upstream"

  # 直连克隆，带浅克隆加速（只拉最新一层，不带历史）
  echo -e "  ${C}▶${N} 直连 github.com（浅克隆，速度快）..."
  if git clone --depth 1 --branch "$BRANCH_TAG" "$UPSTREAM" "$WORK/.tmp_upstream"; then
    echo -e "  ${G}✓${N} 主仓库克隆成功"
  else
    echo -e "  ${Y}⚠${N} 浅克隆失败，尝试完整克隆..."
    rm -rf "$WORK/.tmp_upstream"
    git clone "$UPSTREAM" "$WORK/.tmp_upstream"
    echo -e "  ${G}✓${N} 主仓库克隆成功"
  fi

  # 把 .git 和文件挪到工作目录
  mv "$WORK/.tmp_upstream/.git" "$WORK/.git"
  mv "$WORK/.tmp_upstream"/* "$WORK/" 2>/dev/null || true
  mv "$WORK/.tmp_upstream"/.[!.]* "$WORK/" 2>/dev/null || true
  rm -rf "$WORK/.tmp_upstream"

  # 校验
  if [ ! -f "$WORK/.gitmodules" ]; then
    echo -e "  ${R}✗ 克隆不完整，缺少 .gitmodules${N}"
    exit 1
  fi
  echo -e "  ${G}✓${N} 主仓库就绪"
fi
echo ""

# ══════════ [2/3] 拉取子模块 ══════════
echo -e "${C}【2/3】拉取子模块${N}"

# 同步 .gitmodules 配置
git submodule sync --recursive 2>/dev/null || true

# 列出所有子模块
echo -e "  ${C}▶${N} 子模块列表："
git config -f .gitmodules --get-regexp '^submodule\..*\.path$' | \
  awk '{print "    - " $2}'
echo ""

# 拉取（最多重试 3 次）
SUCCESS=0
for attempt in 1 2 3; do
  echo -e "  ${C}▶${N} 第 $attempt 次尝试拉取子模块 ..."
  if git submodule update --init --recursive --depth 1 2>&1; then
    SUCCESS=1
    break
  fi
  # 深度 1 失败，改用完整拉取
  echo -e "  ${Y}⚠${N} 浅拉取失败，尝试完整拉取..."
  if git submodule update --init --recursive 2>&1; then
    SUCCESS=1
    break
  fi
  echo -e "  ${Y}⚠${N} 第 $attempt 次失败，5 秒后重试..."
  sleep 5
done

if [ "$SUCCESS" != "1" ]; then
  echo -e "  ${R}✗ 子模块拉取失败${N}"
  echo "  手动修复：cd ~/magisk && git submodule update --init --recursive --force"
  exit 1
fi
echo -e "  ${G}✓${N} 子模块拉取完成"
echo ""

# ══════════ [3/3] 校验 ══════════
echo -e "${C}【3/3】校验完整性${N}"

MISSING=0
while IFS= read -r path; do
  if [ ! -e "$path" ] || [ -z "$(ls -A "$path" 2>/dev/null)" ]; then
    echo -e "  ${R}✗ 缺失: $path${N}"
    MISSING=1
  else
    echo -e "  ${G}✓${N} $path"
  fi
done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' | awk '{print $2}')

echo ""

if [ "$MISSING" = "1" ]; then
  echo -e "${Y}⚠ 部分子模块为空，可手动补拉：${N}"
  echo "  cd ~/magisk"
  echo "  git submodule update --init --recursive --force"
  exit 1
fi

echo -e "${G}═════════════════════════════════════════════${N}"
echo -e "${G}   ✓ 源码下载完成${N}"
echo -e "${G}═════════════════════════════════════════════${N}"
echo ""
echo -e "  位置: ${C}$WORK${N}"
echo -e "  版本: ${C}$(git describe --tags 2>/dev/null || echo $BRANCH_TAG)${N}"
echo ""
