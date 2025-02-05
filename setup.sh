#!/bin/bash
echo "=== Setting up 52switch project frontend ==="

# Flutter setup
echo "Setting up Flutter environment..."
if [ ! -f "lib/env_config.dart" ]; then
  cp lib/env_config.dart.example lib/env_config.dart
  echo "Copied env_config.dart.example to env_config.dart in lib."
else
  echo "env_config.dart already exists in lib. Skipping."
fi

# Install Flutter dependencies
echo "Installing Flutter dependencies..."
if command -v flutter &> /dev/null; then
  flutter pub get
else
  echo "Flutter is not installed. Please install it and run this script again."
fi

echo "=== Setup complete ==="
