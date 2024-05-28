#!/bin/sh
# Install Flutter
wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_2.0.6-stable.tar.xz
tar xf flutter_linux_2.0.6-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Enable Flutter web
flutter channel beta
flutter upgrade
flutter config --enable-web


# Install dependencies
flutter pub get

# Build the Flutter web project
flutter build web --release
