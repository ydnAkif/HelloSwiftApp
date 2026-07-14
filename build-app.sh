#!/bin/bash

APP_NAME="HelloSwiftApp"
BUILD_CONFIG="release"

echo " Building $APP_NAME..."
swift build -c $BUILD_CONFIG

echo "📦 Creating .app bundle..."
rm -rf "$APP_NAME.app"
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"

cp ".build/$BUILD_CONFIG/$APP_NAME" "$APP_NAME.app/Contents/MacOS/"

cat > "$APP_NAME.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.akifaydin.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Resources varsa kopyala
if [ -d "Sources/$APP_NAME/Resources" ]; then
    cp -R "Sources/$APP_NAME/Resources/"* "$APP_NAME.app/Contents/Resources/" 2>/dev/null || true
fi

echo "✅ $APP_NAME.app created successfully!"
echo " Location: $(pwd)/$APP_NAME.app"