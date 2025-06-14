#!/bin/bash

# Clean build directory if it exists
rm -rf build

# Create build directory
mkdir -p build

# Compile Swift application for ARM64
swiftc -o build/OnAirMode-arm64 \
    src/OnAirMode.swift \
    src/AudioMonitor.swift \
    src/ShortcutManager.swift \
    src/StatusBarManager.swift \
    src/PermissionManager.swift \
    -framework Cocoa \
    -framework AVFoundation \
    -framework CoreAudio \
    -target arm64-apple-macos11.0

# Compile Swift application for x86_64
swiftc -o build/OnAirMode-x86_64 \
    src/OnAirMode.swift \
    src/AudioMonitor.swift \
    src/ShortcutManager.swift \
    src/StatusBarManager.swift \
    src/PermissionManager.swift \
    -framework Cocoa \
    -framework AVFoundation \
    -framework CoreAudio \
    -target x86_64-apple-macos10.15

# Create universal binary
lipo -create -output build/OnAirMode build/OnAirMode-arm64 build/OnAirMode-x86_64

# Clean up individual architecture binaries
rm build/OnAirMode-arm64 build/OnAirMode-x86_64

# Create app bundle structure
mkdir -p build/OnAirMode.app/Contents/MacOS
mkdir -p build/OnAirMode.app/Contents/Resources

# Copy executable and Info.plist
mv build/OnAirMode build/OnAirMode.app/Contents/MacOS/
cp Info.plist build/OnAirMode.app/Contents/

# Copy assets folder to Resources
cp -r assets build/OnAirMode.app/Contents/Resources/

# Copy app icon
cp icons/AppIcon.icns build/OnAirMode.app/Contents/Resources/AppIcon.icns

# Copy shortcut file to Resources
cp macos-focus-control.shortcut build/OnAirMode.app/Contents/Resources/

# Code sign the application (ad-hoc signing)
codesign --force --deep --sign - build/OnAirMode.app

# Create DMG with Applications folder
mkdir -p build/dmg
cp -r build/OnAirMode.app build/dmg/
ln -s /Applications build/dmg/Applications
hdiutil create -volname "OnAirMode" -srcfolder build/dmg -ov -format UDZO build/OnAirMode.dmg
rm -rf build/dmg

echo "Build complete! App bundle created at build/OnAirMode.app"
echo "DMG created at build/OnAirMode.dmg"
echo "To run: open build/OnAirMode.app"