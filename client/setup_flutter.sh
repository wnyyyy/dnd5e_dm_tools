#!/bin/bash

# Change directory to flutter if it exists, otherwise clone the repository
if cd flutter; then
  git pull
  cd ..
else
  git clone https://github.com/flutter/flutter.git
fi

# List directory contents
ls

# Run flutter doctor
./flutter/bin/flutter doctor

# Clean flutter
./flutter/bin/flutter clean

# Switch to the beta channel
./flutter/bin/flutter channel beta

# Upgrade flutter
./flutter/bin/flutter upgrade

# Enable flutter web
./flutter/bin/flutter config --enable-web

echo $base64_icon | base64 --decode > client/assets/appicon.png 