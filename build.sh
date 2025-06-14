#!/bin/bash

# Clean build directory if it exists
rm -rf build

# Create build directory
mkdir -p build

# Compile Swift application
swiftc -o build/OnAirMode \
    OnAirMode.swift \
    AudioMonitor.swift \
    ShortcutManager.swift \
    StatusBarManager.swift \
    PermissionManager.swift \
    -framework Cocoa \
    -framework AVFoundation \
    -framework CoreAudio

# Create app bundle structure
mkdir -p build/OnAirMode.app/Contents/MacOS
mkdir -p build/OnAirMode.app/Contents/Resources

# Copy executable and Info.plist
mv build/OnAirMode build/OnAirMode.app/Contents/MacOS/
cp Info.plist build/OnAirMode.app/Contents/

# Copy assets folder to Resources
cp -r assets build/OnAirMode.app/Contents/Resources/

# Copy shortcut file to Resources
cp macos-focus-control.shortcut build/OnAirMode.app/Contents/Resources/

echo "Build complete! App bundle created at build/OnAirMode.app"
echo "To run: open build/OnAirMode.app"