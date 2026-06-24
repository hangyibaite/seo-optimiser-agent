#!/bin/bash
# convert-images.sh
# Converts PNG/JPG/JPEG images to WebP format.
# Usage:
#   ./scripts/convert-images.sh <file>           Convert single file
#   ./scripts/convert-images.sh <directory>      Convert all images in directory (recursive)
#   ./scripts/convert-images.sh <file> --quality 80   Set quality (default: 82)
#
# Outputs WebP files alongside originals. Does not delete originals.
# Requires: sharp-cli (auto-installed via npx)

set -e

QUALITY=82

# Parse args
FILES=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --quality)
      QUALITY="$2"
      shift 2
      ;;
    *)
      FILES+=("$1")
      shift
      ;;
  esac
done

if [ ${#FILES[@]} -eq 0 ]; then
  echo "Usage: ./scripts/convert-images.sh <file|directory> [--quality 80]"
  exit 1
fi

if ! command -v npx &> /dev/null; then
  echo "ERROR: npx not found. Install Node.js 18+."
  exit 1
fi

convert_file() {
  local input="$1"
  local ext="${input##*.}"
  local ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  if [[ "$ext_lower" != "png" && "$ext_lower" != "jpg" && "$ext_lower" != "jpeg" ]]; then
    return 0
  fi

  local output="${input%.*}.webp"

  if [ -f "$output" ]; then
    echo "SKIP: $output already exists"
    return 0
  fi

  local input_size=$(wc -c < "$input" | tr -d '[:space:]')

  npx --yes sharp-cli -i "$input" -o "$output" -f webp --quality "$QUALITY" 2>/dev/null

  if [ -f "$output" ]; then
    local output_size=$(wc -c < "$output" | tr -d '[:space:]')
    local savings=$(( (input_size - output_size) * 100 / input_size ))
    echo "CONVERTED: $input → $output (${savings}% smaller)"
    echo "CONVERT_RESULT=$input|$output|$input_size|$output_size"
  else
    echo "ERROR: Failed to convert $input"
  fi
}

CONVERTED=0
SKIPPED=0
FAILED=0

for target in "${FILES[@]}"; do
  if [ -d "$target" ]; then
    while IFS= read -r -d '' file; do
      convert_file "$file"
    done < <(find "$target" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0)
  elif [ -f "$target" ]; then
    convert_file "$target"
  else
    echo "ERROR: $target not found"
    FAILED=$((FAILED + 1))
  fi
done
