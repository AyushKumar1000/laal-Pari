#!/bin/bash
set -e

echo "=== Installing Flutter SDK on Vercel ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

echo "=== Verifying Flutter ==="
flutter doctor -v

echo "=== Building Flutter Web Release ==="
flutter build web --release

echo "=== Build Complete! ==="
