#!/bin/sh

# Startup Xvfb
echo "Starting Xvfb"
# Xvfb -ac :99 -screen 0 1280x1024x16 > /dev/null 2>&1 &
# sudo systemctl start xvfb
systemctl start xvfb
echo "Xvfb started"