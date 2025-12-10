#!/bin/bash

# ShieldVPN Kapsamlı İzleme Scripti
# Build hataları ve uygulama loglarını birlikte izler

PROJECT_PATH="/Users/macm2/Desktop/ShieldVPN-Swift-Apple-App"
SCHEME="ShieldVPN"
DESTINATION="platform=iOS Simulator,name=iPhone 16"

echo "🚀 ShieldVPN İzleme Başlatılıyor..."
echo "=================================="
echo ""

# Build hatalarını kontrol et
check_build() {
    echo "📦 Build kontrol ediliyor..."
    cd "$PROJECT_PATH"
    xcodebuild -project ShieldVPN.xcodeproj -scheme "$SCHEME" -sdk iphonesimulator -destination "$DESTINATION" build 2>&1 | \
    grep -E "(error:|warning:|BUILD)" | \
    sed 's/error:/❌ ERROR:/' | \
    sed 's/warning:/⚠️  WARNING:/' | \
    sed 's/BUILD SUCCEEDED/✅ BUILD SUCCEEDED/' | \
    sed 's/BUILD FAILED/❌ BUILD FAILED/'
    echo ""
}

# İlk kontrol
check_build

# Dosya değişikliklerini izle
echo "👀 Dosya değişiklikleri izleniyor..."
echo "Çıkmak için Ctrl+C basın"
echo ""

# fswatch yoksa basit bir döngü kullan
if command -v fswatch &> /dev/null; then
    fswatch -o "$PROJECT_PATH/ShieldVPN" | while read f; do
        echo "🔄 Değişiklik tespit edildi..."
        sleep 1
        check_build
    done
else
    echo "⚠️  fswatch bulunamadı. Manuel build için 'build' yazın."
    echo "   veya: brew install fswatch"
    echo ""
    while true; do
        read -t 5 -p "Build kontrolü için 'b' yazın (5 saniye sonra tekrar sorar): " input
        if [ "$input" = "b" ]; then
            check_build
        fi
    done
fi

