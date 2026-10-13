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

echo "[3b/5] Apply site Typography overrides to cloned theme"
apply_typography_key() {
  local key="$1"
  local value="$2"
  local file="${THEME_DIR}/_config.yml"
  if grep -q "^${key}:" "${file}"; then
    sed -i "s|^${key}:.*|${key}: \"${value}\"|" "${file}"
  else
    printf '%s: "%s"\n' "${key}" "${value}" >> "${file}"
  fi
}
if [ -f "${ROOT_DIR}/_config.typography.yml" ]; then
  while IFS= read -r line; do
    key="${line%%:*}"
    value="${line#*: }"
    value="${value%\"}"
    value="${value#\"}"
    case "${key}" in
      title_primary|title_secondary) apply_typography_key "${key}" "${value}" ;;
    esac
  done < <(grep -E '^(title_primary|title_secondary):' "${ROOT_DIR}/_config.typography.yml")
else
  echo "WARN: missing _config.typography.yml; sidebar may show Typography / 活版印字."
fi

echo "[4/5] Install theme dependencies"
cd "${THEME_DIR}"
npm install

echo "[5/5] Build and validate"
cd "${ROOT_DIR}"
if [ ! -f "${ROOT_DIR}/_config.typography.yml" ]; then
  echo "WARN: missing _config.typography.yml (title_primary/title_secondary); theme defaults will show."
fi
npx hexo clean
npx hexo g

echo "Typography is ready. Run: npx hexo s"
