# 🚗 Neon Drive

> 네온 감성의 탑다운 레이싱 게임 — Flutter + Flame 엔진으로 제작

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Flame](https://img.shields.io/badge/Flame-1.20-orange)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-green)
![License](https://img.shields.io/badge/License-MIT-blue)

---

## 🎮 게임 소개

**Neon Drive**는 어두운 네온 도시를 배경으로 한 세로 스크롤 레이싱 게임입니다.  
빠르게 달려오는 교통 차량을 피하며 코인을 수집하고 최장 거리를 달리세요.

### 핵심 기능

- 🏎️ **4차선 레이싱** — 좌우 버튼으로 차선 변경
- 💰 **코인 수집** — 달리면서 코인을 모아 새 차 구매
- 🚘 **차고 (Garage)** — 3종 차량 언락 및 선택
- ❤️ **목숨 시스템** — 3개의 하트, 충돌 시 감소
- 🔄 **부활** — 게임오버 후 부활 가능
- 📈 **속도 증가** — 시간이 지날수록 점점 빨라짐

---

## 📱 스크린샷 & 플레이

| 메인 메뉴 | 인게임 | 게임오버 | 차고 |
|:---------:|:------:|:--------:|:----:|
| 네온 타이틀 + 별 파티클 | 탑다운 레이싱 | 스탯 공개 애니메이션 | 차량 선택 |

### 🌐 웹에서 바로 플레이

**[▶ 지금 플레이하기](https://doaidev.github.io/newGame/)**

---

## 🛠️ 기술 스택

| 항목 | 내용 |
|------|------|
| **프레임워크** | Flutter 3.x |
| **게임 엔진** | Flame 1.20 |
| **폰트** | Google Fonts — Orbitron |
| **상태 저장** | shared_preferences |
| **빌드 자동화** | GitHub Actions |
| **배포** | GitHub Pages (Web), APK Artifact (Android) |

---

## 📦 설치 및 실행

### 사전 요구사항

- Flutter SDK `^3.8.0`
- Android Studio 또는 VS Code

### 로컬 실행

```bash
# 저장소 클론
git clone https://github.com/doAiDev/newGame.git
cd newGame

# 패키지 설치
flutter pub get

# 실행 (연결된 기기 또는 에뮬레이터)
flutter run

# 웹 실행
flutter run -d chrome
```

### APK 빌드

```bash
flutter build apk --release
# 결과물: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🚀 자동 빌드 / 배포

`main` 브랜치에 푸시하면 자동으로 실행됩니다.

| 워크플로우 | 트리거 | 결과 |
|-----------|--------|------|
| **Build APK** | `main` push, 수동 | Actions Artifact에 APK 업로드 |
| **Deploy Web** | `main` push, 수동 | GitHub Pages 자동 배포 |

### APK 다운로드

1. GitHub → **Actions** 탭
2. `Build APK` 워크플로우 클릭
3. 하단 **Artifacts** → `neon-drive-X` 다운로드

### 정식 릴리즈 배포

```bash
git tag v1.0.0
git push origin v1.0.0
# → Releases에 APK 자동 첨부
```

---

## 🗂️ 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── core/
│   ├── theme.dart         # 색상 및 테마
│   ├── constants.dart     # 게임 상수
│   └── transitions.dart   # 커스텀 화면 전환
├── game/
│   ├── neon_drive_game.dart        # 메인 게임 로직
│   └── components/
│       ├── player_car.dart         # 플레이어 차량
│       ├── traffic_car.dart        # 교통 차량
│       ├── road.dart               # 도로 렌더링
│       └── coin.dart               # 코인
├── screens/
│   ├── main_menu_screen.dart       # 메인 메뉴
│   ├── game_screen.dart            # 인게임 화면
│   ├── game_over_screen.dart       # 게임오버
│   └── garage_screen.dart          # 차고
├── widgets/
│   ├── neon_button.dart            # 애니메이션 버튼
│   └── neon_text.dart              # 네온 텍스트
└── ads/
    └── ad_manager.dart             # 광고 스텁 (비활성)
```

---

## 🎨 UI 특징

- **Orbitron** 폰트로 미래적인 레이싱 감성
- 버튼 누름 시 **스케일 + 글로우** 애니메이션 + 햅틱 피드백
- 메인 메뉴 **진입 애니메이션** (타이틀 슬라이드인, 버튼 페이드인)
- 화면 전환 **커스텀 트랜지션** (페이드 + 슬라이드)
- 게임오버 **순차 공개 애니메이션** (CRASH! 탄성 → 스탯 슬라이드 → 버튼 페이드)
- 차고 **AnimatedSwitcher** + 스탯 바 채우기 애니메이션

---

## 📋 TODO

- [ ] 실제 AdMob App ID 적용
- [ ] 최고 기록 저장 (shared_preferences)
- [ ] 배경음악 및 효과음 추가
- [ ] iOS 빌드 (.ipa) 배포
- [ ] 리더보드 기능

---

## 📄 라이선스

MIT License — 자유롭게 사용, 수정, 배포 가능합니다.
