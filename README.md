# 🐱 Happit Tracker

**Happit Tracker** is a cute and simple habit tracking app powered by a virtual cat named **Happy**.  
When you keep up with your habits, Happy grows happier — miss a day, and Happy gets a little sad.

This app is perfect for visual habit motivation with a charming emotional feedback system.

---

## ✨ Features

- ✅ Mark habits as done daily
- 💗 Health bar with hearts (0–5)
- 🧠 Smart emotion logic: 9 emotional states
- 🔥 Streak tracker with rewards at 10 and 30 days
- 💾 Data stored locally using SharedPreferences

---

## 🐾 Emotional States

Happy’s emotions are based on:
- Number of hearts (your health level)
- Your current streak count

| Hearts | Streak        | Emotion Level | File        |
|--------|---------------|---------------|-------------|
| 0      | —             | Very Sad 😿    | `1.png`     |
| 1      | —             | Sad 😢         | `2.png`     |
| 2      | —             | Nervous 😟     | `3.png`     |
| 3      | —             | Sleepy 😴      | `4.png`     |
| 4      | —             | Neutral 🙂      | `5.png`     |
| 5      | <10           | Happy 😺       | `6.png`     |
| 5      | ≥10           | Very Happy 😸  | `8.png`     |
| 5      | ≥30           | Ecstatic 🤩    | `9.png`     |

---

## 📸 Screenshots <br>
![on git hub show apps](https://github.com/user-attachments/assets/d9f9a916-f65b-422f-b5a7-4c79a0cfe1c3)

---
You can try  it now by downloading the app from the releases or the <div>[deployed web version](https://happit-tacker.vercel.app/)</div>
---
### Prerequisites

- Flutter 3.x
- Dart SDK >=3.0.0

### Install & Run

```bash
git clone https://github.com/your-username/happit-tracker.git
cd happit-tracker
flutter pub get
flutter run
