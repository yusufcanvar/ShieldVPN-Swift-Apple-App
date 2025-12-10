#!/bin/bash

# ShieldVPN Uygulama Loglarını İzleme Scripti
# Kullanım: ./watch-logs.sh

echo "🔍 ShieldVPN Logları İzleniyor..."
echo "Çıkmak için Ctrl+C basın"
echo "=================================="
echo ""

# Simülatör loglarını izle
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "ShieldVPN"' --level=debug --style=compact

