#!/bin/bash
# Build script for Vercel Flutter deployment

set -e

echo "Installing Flutter dependencies..."
flutter pub get

echo "Building Flutter web..."
flutter build web --release

echo "Build completed successfully!"
