#!/bin/sh
# Install Flutter
curl -o flutter_linux_stable.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_2.0.6-stable.tar.xz
tar xf flutter_linux_stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Enable Flutter web
flutter channel beta
flutter upgrade
flutter config --enable-web


# Install dependencies
flutter pub get

# Build the Flutter web project
flutter build web --release
