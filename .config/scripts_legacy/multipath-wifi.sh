#!/bin/bash

# multipath-wifi-fixed.sh

echo "📡 إعداد توزيع التحميل بين wlan0 و wlan2"

# عرض المسارات الحالية للتشخيص
echo "المسارات الحالية:"
ip route | grep default

# الحصول على الـ gateway من أي واجهة تعمل
GATEWAY=$(ip route | grep default | head -1 | awk '{print $3}')

if [[ -z "$GATEWAY" ]]; then
    echo "❌ لا يوجد gateway محدد. هل أنت متصل بالإنترنت؟"
    echo ""
    echo "للتشخيص:"
    echo "1. تحقق من اتصالك: ping 8.8.8.8"
    echo "2. شوف الـ IP: ip addr show wlan0"
    echo "3. شوف الـ routes: ip route show"
    exit 1
fi

echo "✅ Gateway found: $GATEWAY"

# حذف المسار الافتراضي القديم
sudo ip route del default 2>/dev/null

# إضافة مسارين متساويين
sudo ip route add default scope global \
    nexthop via $GATEWAY dev wlan0 weight 1 \
    nexthop via $GATEWAY dev wlan2 weight 1

# تحسين الإعدادات
sudo sysctl -w net.ipv4.conf.all.rp_filter=0 2>/dev/null
sudo sysctl -w net.ipv4.conf.wlan0.rp_filter=0 2>/dev/null
sudo sysctl -w net.ipv4.conf.wlan2.rp_filter=0 2>/dev/null

echo "✅ تم توزيع التحميل"
echo ""
echo "للتحقق: ip route show default"