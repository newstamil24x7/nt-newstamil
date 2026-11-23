@echo off
title Building NT Newstamil Android App
echo ========================================================
echo   NT Newstamil - Automated Release Builder
echo ========================================================
echo.

set JAVA_HOME=C:\Users\009097\jdk17
set PATH=C:\Users\009097\jdk17\bin;%PATH%
set ANDROID_HOME=C:\Users\009097\AppData\Local\Android\Sdk

cd /d "C:\Users\009097\.gemini\antigravity\brain\7d73607d-bc82-42e4-962a-1da6e4641f84\scratch\newstamil_app"

echo [1/3] Getting latest Flutter dependencies...
call "C:\src\flutter\bin\flutter.bat" pub get

echo.
echo [2/3] Building Release APK for Phone Testing...
call "C:\src\flutter\bin\flutter.bat" build apk --release

echo.
echo [3/3] Building Release AAB Bundle for Google Play Store...
call "C:\src\flutter\bin\flutter.bat" build appbundle --release

echo.
echo ========================================================
echo   BUILD COMPLETED! Organizing files...
echo ========================================================

if not exist "OUTPUTS" mkdir "OUTPUTS"

copy /y "build\app\outputs\flutter-apk\app-release.apk" "OUTPUTS\NT_Newstamil_Testing.apk"
copy /y "build\app\outputs\bundle\release\app-release.aab" "OUTPUTS\NT_Newstamil_PlayStore.aab"

echo.
echo Both files are ready in the OUTPUTS folder:
echo 1. NT_Newstamil_Testing.apk (For your phone)
echo 2. NT_Newstamil_PlayStore.aab (For Play Store Console)
echo.
echo Opening the folder now...
explorer "OUTPUTS"
pause
