#!/bin/bash

# التقاط الشاشة و حفظها في ملف
scrot /tmp/screenshot.png

# تحويل النص من الصورة إلى نص
tesseract /tmp/screenshot.png /tmp/output -l eng

# نسخ النص إلى الحافظة
xclip -sel clip < /tmp/output.txt

# إظهار رسالة نجاح
echo "النص تم نسخه إلى الحافظة"

