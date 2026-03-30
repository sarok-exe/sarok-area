#!/bin/bash

# التحقق من أن الكرتين متصلين
if ip link show wlan0 | grep -q "UP" && ip link show wlan1 | grep -q "UP"; then
    echo "جاري دمج المسارات لزيادة السرعة..."
    
    # حذف المسارات الافتراضية القديمة لتجنب التعارض
    sudo ip route flush exact 0.0.0.0/0
    
    # إضافة المسار المدمج (Multipath)
    sudo ip route add default scope global \
        nexthop via 192.168.1.1 dev wlan0 weight 1 \
        nexthop via 192.168.1.1 dev wlan1 weight 1
    
    echo "السرعة المجنونة مفعلة الآن! 🚀"
else
    echo "تأكد من اتصال wlan0 و wlan1 أولاً."
fi
