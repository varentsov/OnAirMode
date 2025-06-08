#!/bin/bash

echo "Setting up Shortcuts for Do Not Disturb control..."

# Create Turn On Do Not Disturb shortcut
shortcuts create --input-text "Turn On Do Not Disturb" --action "Set Focus"

# Create Turn Off Do Not Disturb shortcut  
shortcuts create --input-text "Turn Off Do Not Disturb" --action "Set Focus"

echo "Shortcuts created! You may need to manually configure them in the Shortcuts app:"
echo "1. Open Shortcuts app"
echo "2. Create 'Turn On Do Not Disturb' shortcut with 'Set Focus' action (Do Not Disturb, Turn On)"
echo "3. Create 'Turn Off Do Not Disturb' shortcut with 'Set Focus' action (Do Not Disturb, Turn Off)"