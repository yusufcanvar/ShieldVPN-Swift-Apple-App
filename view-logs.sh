#!/bin/bash

# iPhone/Simülatör Loglarını Görüntüleme Scripti
# Kullanım: ./view-logs.sh

echo "📱 ShieldVPN Logları İzleniyor..."
echo "=================================="
echo ""

# Çalışan simülatör var mı kontrol et
BOOTED_DEVICE=$(xcrun simctl list devices | grep Booted | head -1 | awk -F'[()]' '{print $2}')

if [ -z "$BOOTED_DEVICE" ]; then
    echo "⚠️  Çalışan simülatör bulunamadı."
    echo "   Xcode'da bir simülatör başlatın veya iPhone'unuzu bağlayın."
    echo ""
    echo "📱 Bağlı cihazlar:"
    xcrun simctl list devices | grep -E "(iPhone|iPad)" | head -10
    exit 1
fi

echo "✅ Cihaz bulundu: $BOOTED_DEVICE"
echo ""
echo "🔍 ShieldVPN uygulamasının logları izleniyor..."
echo "Çıkmak için Ctrl+C basın"
echo ""

# ShieldVPN loglarını filtrele
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "ShieldVPN" OR subsystem contains "com.yusufcanvar.ShieldVPN"' --level=debug --style=compact

