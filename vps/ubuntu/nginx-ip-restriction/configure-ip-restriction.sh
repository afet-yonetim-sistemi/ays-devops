#!/bin/bash

# ==============================================================================
# AYS (Afet Yönetim Sistemi) - IP Kısıtlama Yapılandırma Scripti
# ==============================================================================

# Canlı sunucu için hedef Nginx klasörü
SERVER_CONF_PATH="/etc/nginx/conf.d/ays_ip_restriction.conf"

# Lokal bilgisayarda test ederken hata vermemesi için proje klasörünün içine yazar
if [ -d "/etc/nginx/conf.d" ]; then
    NGINX_CONF_PATH=$SERVER_CONF_PATH
else
    NGINX_CONF_PATH="./ays_ip_restriction.conf"
fi

# İzin Verilecek IP Adresleri Listesi
ALLOWED_IPS=(
    "127.0.0.1"      # Lokal makine
    "192.168.1.50"   # Örnek İç Ağ IP'si
    "203.0.113.195"  # Örnek Güvenli Dış IP
)

echo "🔒 AYS IP Kısıtlama Yapılandırması Başlatılıyor..."

# Eski konfigürasyon dosyasını temizle ve yeniden oluştur
echo "# ==================================================" > "$NGINX_CONF_PATH"
echo "# AYS GÜVENLİ ERİŞİM IP LİSTESİ (Otomatik Oluşturuldu)" >> "$NGINX_CONF_PATH"
echo "# ==================================================" >> "$NGINX_CONF_PATH"

# Döngü ile izin verilen tüm IP'leri dosyaya 'allow' kuralı olarak yaz
for ip in "${ALLOWED_IPS[@]}"; do
    echo "allow $ip;" >> "$NGINX_CONF_PATH"
    echo "➕ İzin verilen IP eklendi: $ip"
done

# Listede olmayan geri kalan herkesi engelle
echo "deny all;" >> "$NGINX_CONF_PATH"
echo "🚫 Geri kalan tüm IP adresleri için engelleme kuralı (deny all) yazıldı."

echo "--------------------------------------------------"
echo "🔄 Nginx konfigürasyonu test ediliyor ve yeniden yükleniyor..."

# Sunucuda Nginx kurulu mu kontrol et
if command -v nginx &> /dev/null; then
    nginx -t && systemctl reload nginx
    echo "✅ IP kısıtlama kuralları başarıyla canlıya alındı!"
else
    echo "⚠️ Uyarı: Nginx sunucuda bulunamadı. Konfigürasyon dosyası yerelde üretildi."
    echo "📁 Üretilen dosya konumu: $NGINX_CONF_PATH"
fi
