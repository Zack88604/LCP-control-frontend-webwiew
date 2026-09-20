#!/bin/zsh
set -euo pipefail

root_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$root_dir"

swift build --configuration release --arch arm64
swift build --configuration release --arch x86_64

app_bundle="$root_dir/release/LCP Control.app"
zip_file="$root_dir/release/LCP-Control-macos-universal.zip"
arm64_binary="$(swift build --configuration release --arch arm64 --show-bin-path)/LCPControlMac"
x86_64_binary="$(swift build --configuration release --arch x86_64 --show-bin-path)/LCPControlMac"

rm -rf "$app_bundle"
rm -f "$zip_file"
mkdir -p "$app_bundle/Contents/MacOS"

lipo -create "$arm64_binary" "$x86_64_binary" -output "$app_bundle/Contents/MacOS/LCP Control"
cp "$root_dir/Resources/Info.plist" "$app_bundle/Contents/Info.plist"
chmod +x "$app_bundle/Contents/MacOS/LCP Control"
plutil -lint "$app_bundle/Contents/Info.plist"

mkdir -p "$root_dir/release"
ditto -c -k --keepParent "$app_bundle" "$zip_file"

printf 'App bundle: %s\n' "$app_bundle"
printf 'Distribution ZIP: %s\n' "$zip_file"
