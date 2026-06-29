# AYS IP Kısıtlama Mekanizması

Bu script, Afet Yönetim Sistemi sunucularındaki kritik servisleri korumak amacıyla Nginx tabanlı IP kısıtlama kurallarını otomatik olarak yapılandırır.

## 🚀 Nasıl Çalıştırılır?

Canlı sunucuda Nginx yapılandırmasını güncelleyebilmesi için scriptin **root/sudo** yetkileriyle çalıştırılması gerekir:

```bash
chmod +x configure-ip-restriction.sh
sudo ./configure-ip-restriction.sh
```

## ⚙️ Yapılandırma

Yeni bir IP adresi izin listesine (Whitelist) eklenmek istendiğinde, script içerisindeki `ALLOWED_IPS` dizisine eklenmesi yeterlidir. Script her çalıştırıldığında kuralları sıfırdan güvenle derler.
