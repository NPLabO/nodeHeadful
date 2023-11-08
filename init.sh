#!/bin/sh

# # Startup Xvfb
# echo "Starting Xvfb"
# Xvfb -ac :99 -screen 0 1280x1024x16 > /dev/null 2>&1 &
# echo "Xvfb started"

bash startXvfb.sh

echo "Starting npm"
npm start
