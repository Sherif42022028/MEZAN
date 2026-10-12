<p align="center">
  <img src="assets/images/mizan_logo.png" width="140" height="140" alt="Mizan Logo" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(6,95,70,0.3);" />
</p>

<h1 align="center">مِيزَان • MIZAN</h1>

<p align="center">
  <b>تطبيق الرقيب المالي الذكي لإدارة المصاريف والميزانيات الشخصية — يعمل أوفلاين 100% وبأعلى معايير الخصوصية</b>
</p>

<p align="center">
  <a href="https://github.com/Sherif42022028/MEZAN/raw/main/releases/mizan-latest.apk">
    <img src="https://img.shields.io/badge/📲_تحميل_التطبيق_مباشرة-APK_(23.9_MB)-065F46?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" />
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/SQLite-Local_Storage-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/الخصوصية-أوفلاين_100%25-10B981?style=for-the-badge" alt="Privacy" />
</p>

---

## 🚀 التثبيت السريع على هاتفك (Direct Download)

لأصدقائنا وأي شخص يريد تجربة واستخدام التطبيق فوراً على هاتف الأندرويد:

### 📥 [اضغط هنا لتحميل ملف التطبيق المباشر (mizan-latest.apk)](https://github.com/Sherif42022028/MEZAN/raw/main/releases/mizan-latest.apk)

#### 📝 خطوات التثبيت في 30 ثانية:
1. اضغط على رابط التحميل الأخضر أعلاه من متصفح الهاتف أو الكمبيوتر.
2. افتح ملف `mizan-latest.apk` بعد اكتمال التحميل.
3. اضغط **تثبيت (Install)**. (إذا طلب هاتفك الإذن لتثبيت التطبيقات من خارج المتجر، اضغط *"السماح بهذا المصدر"*).
4. افتح التطبيق واستمتع بإدارة مالية ذكية وفورية!

---

## ✨ المميزات الرئيسية لتطبيق "ميزان"

| الميزة | الوصف |
| --- | --- |
| 🛡️ **أوفلاين 100% وبدون إنترنت** | كل بياناتك المالية مخزنة محلياً على ذاكرة هاتفك فقط عبر قاعدة بيانات SQLite المشفرة، دون أي خوادم خارجية أو تتبع. |
| ⚡ **قاعدة الـ 3 ثوانٍ للإدخال** | تسجيل أي مصروف أو إيراد في 3 لمسات سريعة فقط مع أزرار المبالغ الفورية (`+50`, `+100`, `+200`, `+500`, `+1000 ج.م`). |
| 💎 **الكارت الزمردي الذكي** | كارت ملخص فاخر يعرض المتبقي في الميزانية، نسبة الاستهلاك الذكية، وتنبيهات الألوان التلقائية (أخضر $\to$ ذهبي $\to$ أحمر). |
| 📅 **المخصص اليومي الآمن** | حساب ذكي لحظي يُظهر كم يمكنك صرفه يومياً حتى نهاية الشهر لتفادي العجز المالي. |
| 📊 **حلقة الإحصائيات (Donut Chart)** | رسوم بيانية تفاعلية دقيقة تكشف ترتيب أعلى التصنيفات استهلاكاً مع ميداليات المراكز (#1، #2، #3). |
| 🗓️ **عزل الشهور وسجل الأيام** | تصفح المعاملات مقسمة باليوم مع إجمالي مصروف كل يوم، والانتقال السلس بين الشهور السابقة والقادمة. |
| 💾 **النسخ الاحتياطي السريع (JSON)** | إمكانية تصدير واستيراد نسخة احتياطية كاملة بنقرة واحدة ومشاركتها عبر واتساب، تيليجرام، أو حفظها على الهاتف. |
| 🌙 **الهوية الزمردية والمخمل الفحمي** | دعم كامل للوضعين النهاري والليلي المريح للعين بتصميم مستوحى من التطبيقات المصرفية العالمية. |

---

## 🛠️ البنية التقنية (Tech Stack)

- **Framework:** Flutter 3.41 (Dart 3.11)
- **State Management:** Provider
- **Local Database:** SQLite via `sqflite`
- **Charts:** `fl_chart`
- **Localization:** Arabic RTL First (`intl`, `flutter_localizations`)
- **Backup & Share:** `share_plus`, `file_picker`, `path_provider`

---

## 💻 تشغيل المشروع للمطورين (For Developers)

إذا كنت ترغب في تشغيل الكود المصدري والتعديل عليه:

```bash
# 1. استنساخ المستودع
git clone https://github.com/Sherif42022028/MEZAN.git

# 2. الدخول لمجلد المشروع
cd MEZAN

# 3. تثبيت الاعتماديات
flutter pub get

# 4. تشغيل التطبيق في وضع التطوير
flutter run

# 5. بناء ملف APK الإنتاجي
flutter build apk --release --split-per-abi --no-tree-shake-icons
```

---

<p align="center">
  صُنع بكل دقة واهتمام ليكون رفيقك المالي الذكي 💚
</p>
