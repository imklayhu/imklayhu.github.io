#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DIR="${ROOT_DIR}/themes/typography"

echo "[1/5] Ensure working directory"
cd "${ROOT_DIR}"

echo "[2/5] Install Typography runtime dependencies"
if grep -q 'packages.aliyun.com' "${ROOT_DIR}/package-lock.json" 2>/dev/null; then
  sed -i 's|https://packages.aliyun.com/[^/]*/npm/npm-registry/|https://registry.npmjs.org/|g' "${ROOT_DIR}/package-lock.json"
fi
npm install --registry=https://registry.npmjs.org/

echo "[3/5] Fetch theme source"
if [ -d "${THEME_DIR}/.git" ]; then
  echo "Theme exists, pulling latest..."
  git -C "${THEME_DIR}" pull --ff-only
else
  rm -rf "${THEME_DIR}"
  git clone https://github.com/SumiMakito/hexo-theme-typography.git "${THEME_DIR}"
fi

echo "[4/5] Install theme dependencies"
cd "${THEME_DIR}"
npm install

echo "[5/5] Build and validate"
cd "${ROOT_DIR}"
npx hexo clean
npx hexo g

echo "Typography is ready. Run: npx hexo s"
