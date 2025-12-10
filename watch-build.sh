#!/bin/bash

# ShieldVPN Build Hatalarını İzleme Scripti
# Kullanım: ./watch-build.sh

echo "🔨 ShieldVPN Build İzleniyor..."
echo "Dosya değişikliklerini izliyor..."
echo "Çıkmak için Ctrl+C basın"
echo "=================================="
echo ""

PROJECT_PATH="/Users/macm2/Desktop/ShieldVPN-Swift-Apple-App"
SCHEME="ShieldVPN"
DESTINATION="platform=iOS Simulator,name=iPhone 16"

# İlk build
echo "📦 İlk build yapılıyor..."
cd "$PROJECT_PATH"
xcodebuild -project ShieldVPN.xcodeproj -scheme "$SCHEME" -sdk iphonesimulator -destination "$DESTINATION" build 2>&1 | grep -E "(error:|warning:|BUILD)" || echo "✅ Build başarılı"

echo ""
echo "⏳ Dosya değişiklikleri izleniyor..."

# Dosya değişikliklerini izle ve build yap
fswatch -o "$PROJECT_PATH/ShieldVPN" | while read f; do
    echo ""
    echo "🔄 Değişiklik tespit edildi, build yapılıyor..."
    xcodebuild -project ShieldVPN.xcodeproj -scheme "$SCHEME" -sdk iphonesimulator -destination "$DESTINATION" build 2>&1 | grep -E "(error:|warning:|BUILD)" || echo "✅ Build başarılı"
    echo ""
done

