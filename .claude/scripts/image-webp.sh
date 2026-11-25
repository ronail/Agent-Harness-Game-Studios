#!/usr/bin/env bash
# image-webp.sh — convert an image to WebP (lossy q90) for retained evidence.
#
# Why: evidence screenshots are the largest files a project keeps. Measured on a
# realistic 1280x720 game frame, lossy q90 WebP is ~22% of the PNG's size (~78%
# saved); lossless WebP is ~86% (~14% saved) because PNG is already lossless.
# The evidence tradeoff is accepted: glyph edges soften (measured max channel
# delta 56 in a text band at q90), so cite a legibility defect from the code or
# the run, not from a softened edge.
#
# Usage: bash .claude/scripts/image-webp.sh <in> [out.webp]
#   <in>        any image the encoder reads (PNG, JPEG, ...)
#   [out.webp]  defaults to <in without extension>.webp beside the input
#
# Encoders, tried in order: cwebp (libwebp), magick, convert, gm. None installed
# is NOT an error: the caller keeps the PNG and records why, per the framework's
# portability rule — evidence must never fail for want of an optional tool.
#
# Output: TSV.
#   converted   <out> <bytes>   written
#   no_encoder  - -             nothing to encode with; keep the original
# Exit: 0 converted, 3 no_encoder, 2 usage, 4 the input cannot be read.
set -u

IN=""; OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *)
      if [ -z "$IN" ]; then IN="$1"
      elif [ -z "$OUT" ]; then OUT="$1"
      else echo "image-webp: one input and one output only" >&2; exit 2
      fi ;;
  esac
  shift
done
[ -n "$IN" ] || { echo "image-webp: an input is needed (try --help)" >&2; exit 2; }
[ -f "$IN" ] || { echo "image-webp: no such file: $IN" >&2; exit 4; }
if [ -z "$OUT" ]; then
  case "$IN" in
    */*) OUT="${IN%.*}.webp" ;;
    *)   OUT="${IN%.*}.webp" ;;
  esac
fi

Q="${IMAGE_WEBP_QUALITY:-90}"

# Each encoder writes to a temp name, so a failed try never leaves a partial file
# at the destination. cwebp is the primary: it is the encoder libwebp ships and
# the only one whose q knob this script's measurements were taken with.
TMP="$OUT.__webp_tmp__"
rm -f "$TMP"
rc=0
if command -v cwebp >/dev/null 2>&1; then
  cwebp -quiet -q "$Q" "$IN" -o "$TMP" || rc=$?
elif command -v magick >/dev/null 2>&1; then
  magick "$IN" -quality "$Q" "$TMP" || rc=$?
elif command -v convert >/dev/null 2>&1; then
  convert "$IN" -quality "$Q" "$TMP" || rc=$?
elif command -v gm >/dev/null 2>&1; then
  gm convert "$IN" -quality "$Q" "$TMP" || rc=$?
else
  printf 'no_encoder\t-\t-\n'; exit 3
fi
if [ "$rc" != 0 ] || [ ! -s "$TMP" ]; then
  rm -f "$TMP"
  # An encoder that exists but cannot read the input is a failure, not a skip:
  # the caller must hear it rather than silently keep a stale picture.
  echo "image-webp: encoder failed (exit $rc) on $IN" >&2
  exit 4
fi
mv -f "$TMP" "$OUT" || { rm -f "$TMP"; exit 4; }
printf 'converted\t%s\t%s\n' "$OUT" "$(wc -c < "$OUT" | tr -d ' ')"
