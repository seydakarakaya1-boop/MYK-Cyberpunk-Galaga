# MYK Cyberpunk Galaga

**iOS İçin Yeni Nesil Retro Arcade Uzay Savaşı**

*Geliştirici: Muhammed Yusuf (12 Yaşında) | Türkiye'de Geliştirildi | Claude AI Yardımıyla Kodlandı*

---

**MYK Cyberpunk Galaga** projesine hoş geldiniz! Bu, mağazada görebileceğiniz sıradan bir uzay vurmaca oyunu değil. Unity, Unreal Engine veya Apple'ın kendi SpriteKit'i gibi hiçbir ağır üçüncü parti oyun motoru kullanılmadan, tamamen sıfırdan **saf Swift** ve **SwiftUI** kullanılarak yazılmış, son derece optimize edilmiş yerel (native) bir iOS arcade deneyimidir.

Henüz 12 yaşındayım ve bu projeyi, yerel bir iOS uygulamasının sınırlarını zorlamak, belleği doğrudan yönetmek ve donanım gücünü sonuna kadar kullanmak için geliştirdim. Ekranda gördüğünüz 120Hz piksel çizimlerinden arka planda çalan prosedürel 8-bit chiptune müziklere kadar her şey doğrudan Swift kodlarıyla matematiksel olarak oluşturuluyor.

---

## Projenin Vizyonu

Temel amacım; Galaga ve Space Invaders gibi 1980'lerin atari salonu efsanelerinin nostaljik büyüsünü yakalamak ve bunu modern iOS teknolojileriyle (örneğin **Dynamic Island**, **Live Activities** ve **Haptic Engine**) birleştirip cyberpunk temalı bir geleceğe taşımaktı. Eski tarz piksel sanatını, en yeni Apple çerçeveleriyle harmanlayarak ortaya eşsiz bir oyun motoru çıkardım.

---

## Temel Teknik Özellikler

### 1. Özel Yazılımsal Piksel Motoru (120Hz ProMotion Destekli)

Standart iOS arayüz elemanlarını (UI) kullanmak yerine, bu oyun ekrandaki her bir pikseli CPU üzerinde anlık olarak hesaplar.

* **`Framebuffer` Mimarisi:** Oyun mantığı saniyede 60 kez (60 FPS) güncellenirken, ProMotion ekranlarda 120 FPS'e kadar akıcı render almak için ara değer (interpolation) hesaplaması yapan raw piksel veri (`UInt32`) dizisi.
* **SpriteROM Sistemi:** Gemiler, düşmanlar ve arayüz elemanları için dışarıdan resim dosyası yüklemek yerine, kod içine gömülü 16x16 ve 32x24 boyutlarında özel hex-encoded (onaltılık) piksel haritaları.
* **Prosedürel Görsel Efektler (VFX):** Gerçek atari tüplü televizyon (CRT) hissi veren tarama çizgileri (scanlines), dinamik olarak üretilen akan yıldız tarlaları, çok katmanlı enerji kalkanları ve patlama şok dalgaları.

### 2. Gerçek Zamanlı 8-Bit Ses Sentezleyici (Synthesizer)

Oyunda hiçbir MP3 veya WAV dosyası kullanılmadı! Tüm müzikler ve ses efektleri oyun oynandığı sırada matematiksel algoritmalarla üretiliyor.

* **`AVAudioEngine` Entegrasyonu:** Ses tamponlarına (audio buffers) doğrudan müdahale.
* **Dinamik Chiptune Müzikler:** PWM kare dalga lead'ler (square wave), üçgen dalga baslar (triangle) ve beyaz gürültü (white noise) davulları kullanılarak oluşturulmuş 5 farklı müzik parçası (Menü, Normal, Normal 2, Boss, Big Boss).
* **Etkileşimli Ses Efektleri (SFX):** Lazer atışları, patlamalar, kalkan kırılmaları ve güçlendirici (power-up) toplama sesleri olay anında milisaniyelik tepkilerle sentezlenir.

### 3. Dynamic Island & Live Activities (`ActivityKit`)

Oyun sadece ana ekranınızla sınırlı kalmaz, tüm telefona yayılır.

* **Gerçek Zamanlı Telemetri:** Skorunuz, bulunduğunuz bölüm, kalan canınız ve Boss savaşlarının durumu anlık olarak iPhone'unuzun **Dynamic Island** bölümüne yansır.
* **Akıllı Mola (Pause) Durumu:** Oyundayken ana ekrana dönerseniz veya başka bir uygulamaya geçerseniz, oyun anında "MOLA" durumuna geçer ve Live Activity üzerinden kilit ekranınızda skorunuzu güvenle saklamaya devam eder.

### 4. Gelişmiş Dokunsal Geri Bildirim (`CoreHaptics`)

Attığınız her mermi, aldığınız her hasar ve patlayan her düşman, Apple'ın Taptic Engine motoruna `UIImpactFeedbackGenerator` ve `UINotificationFeedbackGenerator` kullanılarak hassas titreşimler olarak aktarılır. Bu sayede arcade hissiyatı parmak uçlarınıza ulaşır.

---

## Uzay Filosu (10 Farklı Gemi)

Her birinin hızı, ateş gücü, zırhı ve özel yetenekleri (Ultimate) farklı olan 10 benzersiz geminin kilidini açın ve ustalaşın.

*(Not: Özel yeteneklerin kilidi, oyun içinde 20.000 puana ulaştığınızda kalıcı olarak açılır!)*

1. **ŞAHİN (Dengeli):** Filonun standart savaşçısı. Hız, ateş ve can dengesi mükemmeldir, hatayı affeder.
2. **YILDIRIM (Hızlı):** Son derece çeviktir ve mermileri yağmur gibi yağdırır, ancak zırhı çok kırılgandır.
3. **KALE (Zırhlı):** Yavaş ve ağırdır, ancak 2 ekstra canla başlar ve mermileri iki kat (2x) hasar verir.
4. **NİŞANCI (Keskin Nişancı):** Atış hızı yavaştır ancak mermileri çok hızlı uçar ve hedefe tam 3x hasar verir. Boss avlamak için idealdir.
5. **YELPAZE (Geniş Alan):** Aynı anda 3 farklı yöne çapraz ateş ederek ekrandaki kalabalık düşman dalgalarını saniyeler içinde temizler.
6. **GÖLGE (Hayalet):** *Özel Yetenek: Hayalet Modu.* Radara yakalanmaz. 4 saniye boyunca dokunulmaz olur, düşmanların ve mermilerin içinden hasar almadan geçer.
7. **TOPÇU (Ağır Top):** *Özel Yetenek: Işın Topu.* Devasa bir dikey lazer fırlatır. Lazerin yolundaki her şey sürekli hasar alır ve düşman mermileri bu lazerin içinde eriyip kaybolur.
8. **DAYANIKLI (Tank):** *Özel Yetenek: Onarım.* Hayatta kalmak için tasarlandı. Özel gücüyle anında 1 can yeniler ve ekstra enerji kalkanı açar.
9. **ÖFKE (Cam Top):** *Özel Yetenek: Çılgınlık.* 6 saniye boyunca parmağınızı çekseniz bile inanılmaz bir hızda otomatik ateş eden bir katliam makinesine dönüşür.
10. **KOMUTAN (Elit):** *Özel Yetenek: Filo (Wingmen).* Komutanın gemisi, 8 saniye boyunca sizinle senkronize uçan ve ateş gücünüzü ikiye katlayan iki adet yardımcı drone çağırır.

---

## Oynanış Mekanikleri ve Evren

### Düşman Dalgaları

* **Dronlar (1 HP):** Standart sürüler. Tek atışta yok olurlar.
* **Mech'ler (3 HP):** Zırhlı düşmanlar. Elit dalgalarda sıkça görülürler ve daha fazla atış gerektirirler.
* **Boss'lar (30 HP+):** Her 2 bölümde bir karşınıza çıkarlar. Özel mermi desenleri (pattern) vardır ve öldüklerinde yüksek seviye ganimet (loot) düşürürler.
* **Big Boss'lar (60 HP+):** Her 10 bölümde bir gelen devasa savaş gemileridir. Onları alt etmek size +2 Can, garanti bir Bomba Çekirdeği ve Enerji Kalkanı kazandırır.

### Gelişmiş Savaş Sistemleri

* **Kombo Çarpanı (Combo):** Düşmanları hızlıca yok etmek kombo sayacınızı doldurur ve puanınızı 5 kata (5x) kadar artırır. Hasar almak kombo zincirini kırar.
* **Katmanlı Enerji Kalkanı:** Düşen kalkan kapsüllerini toplamak geminizin etrafında dönen katmanlı bir güç alanı oluşturur. Bu kalkan gelen mermileri emer ve yukarı doğru dost mermiler olarak geri sektirir.
* **Bomba Çekirdeği:** Nadir düşen bu çekirdek, alındığı anda ekranı kaplayan bir şok dalgası yaratır. Tüm düşman mermilerini siler, küçük düşmanları yok eder ve Boss'lara ağır hasar verir.
* **Elit ve Bonus Bölümler:** Her 5 bölümde bir sadece Mech'lerden oluşan Elit dalgalarla yüzleşirsiniz. Her 7 bölümde bir ise düşmanların ateş etmediği, sadece vurup ekstra puan kazanabileceğiniz Bonus (Pacifist) bölümler gelir.

### Dinamik Zorluk Ölçeklemesi

Oyun, seçtiğiniz zorluk seviyesine (**KOLAY**, **NORMAL**, **ZOR**) göre mekaniklerini anında değiştirir.

* **ZOR Modda:** Düşman mermileri %45 daha hızlı gelir, atış sıklıkları iki katına çıkar, boss'ların canı 2.2 kat artar ve siz maceraya sadece 3 canla başlarsınız!
