# Skyphrase ✈️

Havacılık terminolojisini ve ICAO telsiz frazeolojisini oyunlaştırarak öğreten
Duolingo tarzı bir Flutter uygulaması (MVP).

## Şu an ne var?

- **3 ünite / 7 ders / 28 egzersiz** gerçek havacılık içeriğiyle:
  - Ünite 1: ICAO Fonetik Alfabe (Alfa, Bravo, Charlie…)
  - Ünite 2: Temel Telsiz Frazeolojisi (Roger, Wilco, Affirm…)
  - Ünite 3: Havacılık Sayıları (Tree, Fife, Niner)
- **3 egzersiz tipi:** çoktan seçmeli, eşleştirme, kelime bankası (cümle kurma)
- **İlerleme sistemi:** XP, günlük seri (streak), sırayla açılan dersler
- Cihazda kalıcı kayıt (`shared_preferences`)
- Özgün marka/renk paleti (marka çatışmasını önlemek için Duolingo'nun
  yeşilinden ve maskotundan bilinçli olarak uzak)

## Kurulum

Bu paket `lib/`, `pubspec.yaml` ve `assets/` içerir ama platform klasörlerini
(android/ios) içermez. Onları tek komutla üret:

```bash
cd skyphrase
flutter create --org com.SENIN_ADIN .   # android/ios/web klasörlerini ekler,
                                          # mevcut lib/ ve pubspec'e dokunmaz
flutter pub get
flutter run
```

> Not: App Store'a yüklemek için macOS + Xcode + Apple Developer hesabı
> (yıllık 99 USD) gerekir. Android tarafı için Google Play hesabı (tek seferlik
> 25 USD).

## Yeni ders eklemek

Kod yazmana gerek yok — `assets/courses/aviation_en.json` dosyasına ünite/ders
ekle. Egzersiz şablonları:

```json
{ "type": "multipleChoice", "prompt": "...", "options": ["..."], "correctIndex": 0 }
{ "type": "matchPairs", "prompt": "...", "pairs": [{ "left": "...", "right": "..." }] }
{ "type": "wordBank", "prompt": "...", "correctOrder": ["..."], "distractors": ["..."] }
```

## Mimari

```
lib/
  models/     -> Course, Unit, Lesson, Exercise (JSON'dan parse)
  data/       -> CourseRepository (asset'ten yükler)
  state/      -> Provider'lar (ilerleme, kurs, ders oturumu)
  screens/    -> Ana harita, ders, sonuç ekranları
  widgets/    -> Egzersiz görünümleri + ortak bileşenler
assets/courses/aviation_en.json  -> tüm ders içeriği
```
