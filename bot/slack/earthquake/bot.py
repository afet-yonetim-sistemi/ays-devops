import os
import requests
import time
from bs4 import BeautifulSoup
 
SLACK_WEBHOOK_URL = os.environ.get("SLACK_WEBHOOK_URL", "")
MAGNITUDE_THRESHOLD = float(os.environ.get("MAGNITUDE_THRESHOLD", "5.0"))
CHECK_INTERVAL = int(os.environ.get("CHECK_INTERVAL", "300"))

sent_earthquakes = set()

def send_to_slack(magnitude, location, time_str, depth, is_test=False):
    if is_test:
        payload = {
            "text": "🚀 *AYS Deprem Takip Botu Başarıyla Başlatıldı!* \nŞu andan itibaren lokalinizden AFAD verilerini dinlemeye başladı."
        }
    else:
        payload = {
            "text": f"🚨 AFAD RESMİ DEPREM BİLDİRİMİ: {location} - Büyüklük: {magnitude}",
            "attachments": [
                {
                    "color": "#FF4500",
                    "title": "AFAD Deprem Bilgilendirme Sistemi",
                    "fields": [
                        {"title": "Büyüklük (Mw)", "value": f"*{magnitude}*", "short": True},
                        {"title": "Konum / Yer", "value": location, "short": True},
                        {"title": "Tarih ve Saat", "value": str(time_str), "short": True},
                        {"title": "Derinlik", "value": f"{depth} km", "short": True}
                    ],
                    "footer": "Afet Yönetim Sistemi (AYS) DevOps Otomasyonu"
                }
            ]
        }
    
    try:
        res = requests.post(SLACK_WEBHOOK_URL, json=payload, timeout=10)
        if res.status_code == 200:
            if is_test:
                print("📢 Slack'e başarıyla AÇILIŞ TEST MESAJI gönderildi!")
            else:
                print(f"📢 Slack Kanalına Başarıyla Bildirildi: {location} ({magnitude})")
        else:
            print(f"❌ Slack Hatası. Kod: {res.status_code}")
    except Exception as e:
        print(f"❌ Slack Bağlantı Hatası: {e}")

def check_earthquakes():
    afad_html_url = "https://afad.gov.tr"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    
    try:
        response = requests.get(afad_html_url, headers=headers, timeout=15)
        if response.status_code != 200:
            print(f"⚠️ AFAD sayfasına erişilemedi. Durum Kodu: {response.status_code}")
            return
            
        soup = BeautifulSoup(response.text, 'html.parser')
        table = soup.find('table')
        
        if not table:
            print("❌ Tablo yapısı okunamadı.")
            return
            
        rows = table.find_all('tr')[1:] # Başlığı atla
        print(f"✅ AFAD Canlı Sayfası Okundu. Son sarsıntılar taranıyor...")
        
        for row in rows:
            cols = row.find_all('td')
            if len(cols) < 7:
                continue
                
            time_str = cols[0].text.strip()
            depth = cols[3].text.strip()
            
            raw_mag = cols[4].text.strip().replace(',', '.')
            magnitude = float(raw_mag) if raw_mag else 0.0
            
            location = cols[6].text.strip()
            
            eq_id = f"{time_str}_{location}_{magnitude}"

            if magnitude >= MAGNITUDE_THRESHOLD and eq_id not in sent_earthquakes:
                send_to_slack(magnitude, location, time_str, depth)
                sent_earthquakes.add(eq_id)

    except Exception as e:
        print(f"❌ Veri işleme hatası: {e}")

if __name__ == "__main__":
    print("🚨 AYS - Resmi AFAD Deprem Takip Botu Başlatıldı...")
    
    # Send a test message to Slack on startup to verify the connection.
    send_to_slack(0, "", "", "", is_test=True)
    
    while True:
        check_earthquakes()
        time.sleep(CHECK_INTERVAL)
