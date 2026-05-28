# Neon Drive — Unity 세틄 가이드

## 1. Unity 열기

1. **Unity Hub** 연기
2. **Add project from disk** → `unity-project/` 폴더 선택
3. Unity **2022.3 LTS** 로 열기

---

## 2. 시염 세틄

### MainMenu 시염
- `File > New Scene` → `MainMenu` 로 저장
- **UI Canvas** 생성 (Screen Space — Overlay)
  - NEON DRIVE 타이틀 (TextMeshPro)
  - PLAY 버튼 → `SceneManager.LoadScene("Game")` 연결
  - GARAGE 버튼

### Game 시염

#### 필수 오브젝트

| 오브젝트 | 컴포넌트 | 태그 |
|----------|-----------|-----|
| GameManager | `GameManager.cs` | — |
| Main Camera | `CameraShake.cs` | — |
| Player | `PlayerController.cs`, `Rigidbody2D`, `PolygonCollider2D` (Is Trigger) | `Player` |
| TrafficSpawner | `TrafficSpawner.cs` | — |
| CoinSpawner | `CoinSpawner.cs` | — |
| Road_1, Road_2 | `RoadScroller.cs` (Tile Height = 20) | — |

#### 프리팩

**TrafficCar Prefab:**
- Sprite Renderer (차 이미지)
- `TrafficCar.cs`
- `NeonGlow.cs`
- BoxCollider2D (Is Trigger) → Tag: `Traffic`

**Coin Prefab:**
- Sprite Renderer (코인 이미지)
- `CoinController.cs`
- CircleCollider2D (Is Trigger) → Tag: `Coin`

#### UI Canvas 구조
```
Canvas
├── HUD
│   ├── CoinsText (TMP)
│   ├── DistanceText (TMP)
│   ├── Hearts (Heart1, Heart2, Heart3 Image)
│   └── PauseButton
├── GameOverPanel
│   ├── CRASH! (TMP)
│   ├── GOCoinsText
│   ├── GODistanceText
│   ├── ReviveButton
│   ├── RetryButton
└── Joystick
├── Background (Image, 120x120, circle sprite)
└── Handle (Image, 50x50, circle sprite)
```

#### 조이스틱 세틄
- `Joystick` 오브젝트에 `Joystick.cs` 컴포넌트 추가
- `Background` 슬롯에 Joystick Background RectTransform 연결
- `Handle` 슬롯에 Handle RectTransform 연결
- **Horizontal Only** 체크 (x축만 사용)

#### UIManager 연결
- 빈 오브젝트에 `UIManager.cs` 컴포넌트 추가
- Inspector에서 각 필드 연결 (코인 Text, 하트 Image[], 패널들)
- 버튼 OnClick → UIManager 함수 연결

---

## 3. 차 스프라이트 추천 리소스

무료 레이싱 스프라이트:
- **Kenney.nl** → `Racing Pack` (free)
- **Unity Asset Store** → `Simple Racer` (free)

---

## 4. 빌드 (Android APK)

1. `File > Build Settings`
2. Platform: **Android** → Switch Platform
3. `Player Settings` → Company/Product Name 설정
4. **Build and Run**
