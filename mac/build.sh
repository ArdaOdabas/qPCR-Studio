#!/bin/bash
# Builds "qPCR Studio.app" (universal: Apple Silicon + Intel) and packs it into qPCR-Studio.dmg
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
OUT="$PWD/build"
APP="$OUT/qPCR Studio.app"
VERSION="1.0"
rm -rf "$OUT"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "› compiling"
swiftc -O -target arm64-apple-macos12  main.swift -o "$OUT/qpcr-arm64"
swiftc -O -target x86_64-apple-macos12 main.swift -o "$OUT/qpcr-x86_64"
lipo -create "$OUT/qpcr-arm64" "$OUT/qpcr-x86_64" -output "$APP/Contents/MacOS/qPCR Studio"
rm "$OUT/qpcr-arm64" "$OUT/qpcr-x86_64"

echo "› icon"
swift icon.swift "$OUT/icon1024.png"
ICONSET="$OUT/AppIcon.iconset"; mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s "$OUT/icon1024.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  d=$((s*2)); sips -z $d $d "$OUT/icon1024.png" --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"

cp "$ROOT/qpcr-studio.html" "$APP/Contents/Resources/index.html"

cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>qPCR Studio</string>
  <key>CFBundleDisplayName</key><string>qPCR Studio</string>
  <key>CFBundleIdentifier</key><string>com.qpcrstudio.app</string>
  <key>CFBundleExecutable</key><string>qPCR Studio</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.education</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSHumanReadableCopyright</key><string>ΔΔCt analysis for LightCycler 480</string>
</dict></plist>
EOF

echo "› signing (ad-hoc)"
codesign --force --deep --sign - "$APP"

echo "› dmg"
STAGE="$OUT/dmg"; mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
rm -f "$ROOT/qPCR-Studio.dmg"
hdiutil create -volname "qPCR Studio" -srcfolder "$STAGE" -fs HFS+ -format UDZO -ov "$ROOT/qPCR-Studio.dmg" >/dev/null
rm -rf "$STAGE"
echo "✓ $ROOT/qPCR-Studio.dmg"
