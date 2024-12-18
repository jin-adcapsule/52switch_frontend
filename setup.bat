@echo off
echo === Setting up 52switch project front end ===

:: Flutter setup
echo Setting up Flutter environment...
if not exist "lib\env_config.dart" (
  copy "lib\env_config.dart.example" "lib\env_config.dart"
  echo Copied env_config.dart.example to env_config.dart in lib.
) else (
  echo env_config.dart already exists in lib. Skipping.
)

:: Install Flutter dependencies
echo Installing Flutter dependencies...
if exist "flutter.bat" (
  flutter pub get
) else (
  echo Flutter is not installed. Please install it and run this script again.
)

echo === Setup complete ===
