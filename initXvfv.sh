#!/bin/sh

# Startup Xvfb
echo "Init Xvfb"
# sudo systemctl daemon-reload
# sudo systemctl enable xvfb
systemctl daemon-reload
systemctl enable xvfb
echo "Xvfb initialized"