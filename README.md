# TrackFi

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![WIP](https://img.shields.io/badge/Status-Work_in_Progress-yellow?style=for-the-badge)

TrackFi is a modern finance tracker app designed with clean UI principles, local-first privacy, and an eye toward smart analysis. Built in Flutter as a **university project**, TrackFi focuses on simplicity and extensibility, offering a responsive dashboard and flexible architecture.

> ⚠️ This app is under active development and not intended for production use (yet).

---

## 🌟 Features (Work in Progress)

- [x] Light/Dark themes with custom gradients
- [x] Responsive dashboard layout
- [ ] Modular bottom navigation bar
- [ ] Welcome & onboarding screens
- [ ] Secure local pin + biometric auth
- [ ] Manual account + transaction input
- [ ] In-app analytics UI
- [ ] Optional AI integration (planned)
- [ ] Encrypted local `.sqlite` database

---

## 🚀 Getting Started

1. **Clone the repo**:

   ```bash
   git clone https://github.com/punkrock34/trackfi.git
   cd trackfi
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run the app**:

   ```bash
   flutter run
   ```

Requires Flutter and an emulator or connected device.

---

## 🧱 Project Structure

```bash
lib/
├── app/               # Theme and global config
├── features/          # Domain-specific screens (dashboard, auth, etc.)
├── shared/            # Reusable widgets, helpers
```

---

## 🧠 AI Plans (Optional)

The architecture allows future integration with an LLM (e.g., Hugging Face pay-per-use API) to provide:

- Financial summaries
- Spending pattern analysis
- Smart suggestions

This is experimental and will be added later **only if needed** for the university submission.

---

## 🔐 Security Design (Planned)

- Local-only data storage
- Biometric authentication fallback
- SQLite DB with encryption planned for sensitive records

---

## 📄 License

This project is for educational purposes and not yet licensed for public use.  
Final licensing and asset attribution will be added if and when it’s released publicly.

---

## 🧑‍🎓 Made by

**Popus Razvan Adrian**  
Built as part of a university course project to explore modern mobile development and application architecture.  
GitHub: [@punkrock34](https://github.com/punkrock34)
