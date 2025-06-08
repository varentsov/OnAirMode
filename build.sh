#!/bin/bash

# Create build directory
mkdir -p build

# Compile Swift application
swiftc -o build/MicMonitor MicMonitor.swift \
    -framework Cocoa \
    -framework AVFoundation \
    -framework CoreAudio

# Create app bundle structure
mkdir -p build/MicMonitor.app/Contents/MacOS
mkdir -p build/MicMonitor.app/Contents/Resources

# Copy executable and Info.plist
cp build/MicMonitor build/MicMonitor.app/Contents/MacOS/
cp Info.plist build/MicMonitor.app/Contents/

echo "Build complete! App bundle created at build/MicMonitor.app"
echo "To run: open build/MicMonitor.app"