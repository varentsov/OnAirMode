#!/bin/bash

echo "Installing macOS Focus Control shortcut..."

# Check if the shortcut file exists
if [ ! -f "macos-focus-control.shortcut" ]; then
    echo "❌ Error: macos-focus-control.shortcut not found in current directory"
    exit 1
fi

# Copy the shortcut to a temporary location with a clear name
cp "macos-focus-control.shortcut" "/tmp/macos-focus-control.shortcut"

echo "📱 Opening shortcut for import..."
echo "This will open the Shortcuts app and import the shortcut."
echo "You may need to:"
echo "1. Click 'Add Shortcut' when prompted"
echo "2. Allow any permissions requested"
echo "3. The shortcut will be named 'macos-focus-control'"

# Open the shortcut file which should trigger import
open "/tmp/macos-focus-control.shortcut"

echo ""
echo "⏳ Waiting for import to complete..."
sleep 5

# Check if shortcuts command is available and list shortcuts
if command -v shortcuts &> /dev/null; then
    echo ""
    echo "📋 Current shortcuts:"
    shortcuts list | grep -E "(macos-focus-control|Focus|DND|Do Not Disturb)" || echo "No relevant shortcuts found yet"
    
    echo ""
    echo "🧪 Testing the shortcut..."
    echo "Testing 'status' command:"
    shortcuts run "macos-focus-control" --input-text "status" 2>/dev/null || echo "Shortcut not ready yet"
else
    echo "⚠️  Shortcuts command not available"
fi

echo ""
echo "✅ Installation script complete!"
echo ""
echo "Next steps:"
echo "1. Verify the shortcut was imported in the Shortcuts app"
echo "2. Run the MicMonitor app to test automatic DND control"
echo "3. Test manually with: shortcuts run \"macos-focus-control\" --input-text \"status\""

# Clean up
rm -f "/tmp/macos-focus-control.shortcut"