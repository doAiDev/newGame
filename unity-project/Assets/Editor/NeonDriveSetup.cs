using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.UI;
using TMPro;

public class NeonDriveSetup : EditorWindow
{
    [MenuItem("NeonDrive/게임 씨 자동 세틄")]
    public static void SetupScene()
    {
        if (!EditorUtility.DisplayDialog("Neon Drive Setup",
            "현재 씨을 Neon Drive 게임 씨으로 세팅합니다.\n기존 오브젝트는 유지됩니다.",
            "세팅 시작", "취소"))
            return;

        // Tags
        AddTag("Traffic");
        AddTag("Coin");
        AddTag("Player");

        // Camera
        var cam = Camera.main;
        if (cam != null)
        {
            cam.orthographic = true;
            cam.orthographicSize = 10;
            cam.transform.position = new Vector3(0, 0, -10);
            cam.backgroundColor = new Color(0.027f, 0.027f, 0.078f);
            cam.clearFlags = CameraClearFlags.SolidColor;
            EnsureComponent<CameraShake>(cam.gameObject);
        }

        // GameManager
        var gm = new GameObject("GameManager");
        gm.AddComponent<GameManager>();

        // Road
        CreateRoad("Road",  new Vector3(0,  0, 1));
        CreateRoad("Road2", new Vector3(0, 20, 1));

        // Lane lines
        CreateLaneLine("Lane1", -2.1f);
        CreateLaneLine("Lane2", -0.7f);
        CreateLaneLine("Lane3",  0.7f);
        CreateLaneLine("Lane4",  2.1f);

        // Player
        var player = CreateSquareSprite("Player", new Vector3(0, -6, 0),
            new Vector3(0.75f, 1.3f, 1), new Color(0f, 1f, 0.78f));
        player.tag = "Player";
        var pc = player.AddComponent<PlayerController>();
        pc.LaneWidth = 1.4f;
        pc.TotalLanes = 4;
        var rb = player.AddComponent<Rigidbody2D>();
        rb.gravityScale = 0;
        rb.constraints = RigidbodyConstraints2D.FreezeRotation;
        var col = player.AddComponent<BoxCollider2D>();
        col.isTrigger = true;

        // TrafficSpawner
        var ts = new GameObject("TrafficSpawner");
        ts.AddComponent<TrafficSpawner>();

        // CoinSpawner
        var cs = new GameObject("CoinSpawner");
        cs.AddComponent<CoinSpawner>();

        // Traffic Prefab
        CreateTrafficPrefab();

        // Coin Prefab
        CreateCoinPrefab();

        // UI
        SetupUI();

        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        EditorUtility.DisplayDialog("Neon Drive Setup",
            "✅ 세팅 완료!\n\n나머지 작업:\n" +
            "1. TrafficSpawner에 Traffic 프리팩 연결\n" +
            "2. CoinSpawner에 Coin 프리팩 연결\n" +
            "3. UIManager Inspector 필드 연결\n" +
            "4. Ctrl+S 로 저장",
            "확인");
    }

    static void CreateRoad(string name, Vector3 pos)
    {
        var road = CreateSquareSprite(name, pos, new Vector3(5.8f, 20f, 1),
            new Color(0.1f, 0.1f, 0.18f));
        road.AddComponent<RoadScroller>();
    }

    static void CreateLaneLine(string name, float x)
    {
        var line = CreateSquareSprite(name, new Vector3(x, 0, 0.5f),
            new Vector3(0.03f, 20f, 1), new Color(0.47f, 0.18f, 1f, 0.3f));
        line.AddComponent<RoadScroller>();
    }

    static GameObject CreateSquareSprite(string name, Vector3 pos, Vector3 scale, Color color)
    {
        var go = new GameObject(name);
        go.transform.position = pos;
        go.transform.localScale = scale;
        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/UISprite.psd");
        if (sr.sprite == null)
            sr.sprite = Resources.GetBuiltinResource<Sprite>("Sprites/Square.png");
        sr.color = color;
        return go;
    }

    static void CreateTrafficPrefab()
    {
        if (!AssetDatabase.IsValidFolder("Assets/Prefabs"))
            AssetDatabase.CreateFolder("Assets", "Prefabs");

        var go = CreateSquareSprite("TrafficCar", Vector3.zero,
            new Vector3(0.75f, 1.3f, 1), new Color(1f, 0.18f, 0.47f));
        go.tag = "Traffic";
        go.AddComponent<TrafficCar>();
        var col = go.AddComponent<BoxCollider2D>();
        col.isTrigger = true;

        PrefabUtility.SaveAsPrefabAsset(go, "Assets/Prefabs/TrafficCar.prefab");
        Object.DestroyImmediate(go);

        // TrafficSpawner에 연결
        var spawner = Object.FindObjectOfType<TrafficSpawner>();
        if (spawner != null)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/Prefabs/TrafficCar.prefab");
            spawner.CarPrefabs = new GameObject[] { prefab };
        }
    }

    static void CreateCoinPrefab()
    {
        if (!AssetDatabase.IsValidFolder("Assets/Prefabs"))
            AssetDatabase.CreateFolder("Assets", "Prefabs");

        var go = new GameObject("Coin");
        go.tag = "Coin";
        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = Resources.GetBuiltinResource<Sprite>("Sprites/Knob.png");
        sr.color = new Color(1f, 0.84f, 0f);
        go.transform.localScale = new Vector3(0.6f, 0.6f, 1f);
        go.AddComponent<CoinController>();
        var col = go.AddComponent<CircleCollider2D>();
        col.isTrigger = true;

        PrefabUtility.SaveAsPrefabAsset(go, "Assets/Prefabs/Coin.prefab");
        Object.DestroyImmediate(go);

        var spawner = Object.FindObjectOfType<CoinSpawner>();
        if (spawner != null)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/Prefabs/Coin.prefab");
            spawner.CoinPrefab = prefab;
        }
    }

    static void SetupUI()
    {
        // Canvas
        var canvasGO = new GameObject("Canvas");
        var canvas = canvasGO.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvasGO.AddComponent<CanvasScaler>();
        canvasGO.AddComponent<GraphicRaycaster>();

        var scaler = canvasGO.GetComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1080, 1920);

        // HUD
        var hud = new GameObject("HUD");
        hud.transform.SetParent(canvasGO.transform, false);

        var coinsText = CreateTMPText(hud, "CoinsText", "0",
            new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
            new Vector2(0, -80), 36, Color.yellow);

        var distText = CreateTMPText(hud, "DistanceText", "0.0 km",
            new Vector2(1f, 1f), new Vector2(1f, 1f),
            new Vector2(-40, -80), 28, new Color(0f, 1f, 0.78f));

        // Hearts
        var hearts = new GameObject("Hearts");
        hearts.transform.SetParent(hud.transform, false);
        var hrect = hearts.AddComponent<RectTransform>();
        hrect.anchorMin = new Vector2(0, 1);
        hrect.anchorMax = new Vector2(0, 1);
        hrect.anchoredPosition = new Vector2(60, -70);
        var hlg = hearts.AddComponent<HorizontalLayoutGroup>();
        hlg.spacing = 8;

        var heartImages = new Image[3];
        for (int i = 0; i < 3; i++)
        {
            var h = new GameObject($"Heart{i + 1}");
            h.transform.SetParent(hearts.transform, false);
            var img = h.AddComponent<Image>();
            img.color = new Color(1f, 0.18f, 0.47f);
            var r = h.GetComponent<RectTransform>();
            r.sizeDelta = new Vector2(40, 40);
            heartImages[i] = img;
        }

        // GameOver Panel
        var goPanel = CreatePanel(canvasGO, "GameOverPanel", new Color(0.027f, 0.027f, 0.078f, 0.95f));
        CreateTMPText(goPanel, "CrashText", "CRASH!",
            new Vector2(0.5f, 0.65f), new Vector2(0.5f, 0.65f),
            Vector2.zero, 72, new Color(1f, 0.18f, 0.47f));
        var goCoins = CreateTMPText(goPanel, "GOCoinsText", "0",
            new Vector2(0.5f, 0.52f), new Vector2(0.5f, 0.52f),
            Vector2.zero, 40, Color.yellow);
        var goDist = CreateTMPText(goPanel, "GODistText", "0.00 km",
            new Vector2(0.5f, 0.44f), new Vector2(0.5f, 0.44f),
            Vector2.zero, 40, new Color(0f, 1f, 0.78f));
        CreateNeonButton(goPanel, "ReviveBtn", "REVIVE",
            new Vector2(0.5f, 0.32f), new Color(0f, 1f, 0.78f));
        CreateNeonButton(goPanel, "RetryBtn", "RETRY",
            new Vector2(0.5f, 0.22f), new Color(0.47f, 0.18f, 1f));
        CreateNeonButton(goPanel, "HomeBtn", "HOME",
            new Vector2(0.5f, 0.12f), new Color(0.4f, 0.4f, 0.5f));
        goPanel.SetActive(false);

        // Joystick
        var joystickGO = new GameObject("Joystick");
        joystickGO.transform.SetParent(canvasGO.transform, false);
        var jRect = joystickGO.AddComponent<RectTransform>();
        jRect.anchorMin = new Vector2(0.5f, 0);
        jRect.anchorMax = new Vector2(0.5f, 0);
        jRect.anchoredPosition = new Vector2(0, 120);
        jRect.sizeDelta = new Vector2(200, 200);

        var bg = new GameObject("Background");
        bg.transform.SetParent(joystickGO.transform, false);
        var bgImg = bg.AddComponent<Image>();
        bgImg.color = new Color(1f, 1f, 1f, 0.08f);
        var bgRect = bg.GetComponent<RectTransform>();
        bgRect.anchorMin = Vector2.zero;
        bgRect.anchorMax = Vector2.one;
        bgRect.offsetMin = Vector2.zero;
        bgRect.offsetMax = Vector2.zero;

        var handle = new GameObject("Handle");
        handle.transform.SetParent(joystickGO.transform, false);
        var handleImg = handle.AddComponent<Image>();
        handleImg.color = new Color(0f, 1f, 0.78f, 0.6f);
        var hRect = handle.GetComponent<RectTransform>();
        hRect.anchorMin = new Vector2(0.5f, 0.5f);
        hRect.anchorMax = new Vector2(0.5f, 0.5f);
        hRect.sizeDelta = new Vector2(70, 70);
        hRect.anchoredPosition = Vector2.zero;

        var joystick = joystickGO.AddComponent<Joystick>();
        joystick.Background = bgRect;
        joystick.Handle = hRect;
        joystick.HorizontalOnly = true;

        // UIManager
        var uiMgrGO = new GameObject("UIManager");
        uiMgrGO.transform.SetParent(canvasGO.transform, false);
        var uiMgr = uiMgrGO.AddComponent<UIManager>();
        uiMgr.CoinsText = coinsText.GetComponent<TextMeshProUGUI>();
        uiMgr.DistanceText = distText.GetComponent<TextMeshProUGUI>();
        uiMgr.HeartIcons = heartImages;
        uiMgr.GameOverPanel = goPanel;
        uiMgr.GOCoinsText = goCoins.GetComponent<TextMeshProUGUI>();
        uiMgr.GODistanceText = goDist.GetComponent<TextMeshProUGUI>();
    }

    static GameObject CreatePanel(GameObject parent, string name, Color color)
    {
        var go = new GameObject(name);
        go.transform.SetParent(parent.transform, false);
        var img = go.AddComponent<Image>();
        img.color = color;
        var rect = go.GetComponent<RectTransform>();
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;
        return go;
    }

    static GameObject CreateTMPText(GameObject parent, string name, string text,
        Vector2 anchorMin, Vector2 anchorMax, Vector2 pos, float fontSize, Color color)
    {
        var go = new GameObject(name);
        go.transform.SetParent(parent.transform, false);
        var tmp = go.AddComponent<TextMeshProUGUI>();
        tmp.text = text;
        tmp.fontSize = fontSize;
        tmp.color = color;
        tmp.alignment = TextAlignmentOptions.Center;
        var rect = go.GetComponent<RectTransform>();
        rect.anchorMin = anchorMin;
        rect.anchorMax = anchorMax;
        rect.anchoredPosition = pos;
        rect.sizeDelta = new Vector2(300, 60);
        return go;
    }

    static void CreateNeonButton(GameObject parent, string name, string label,
        Vector2 anchor, Color color)
    {
        var go = new GameObject(name);
        go.transform.SetParent(parent.transform, false);
        var img = go.AddComponent<Image>();
        img.color = new Color(color.r * 0.15f, color.g * 0.15f, color.b * 0.15f, 0.9f);
        go.AddComponent<Button>();
        var rect = go.GetComponent<RectTransform>();
        rect.anchorMin = new Vector2(anchor.x - 0.25f, anchor.y);
        rect.anchorMax = new Vector2(anchor.x + 0.25f, anchor.y);
        rect.anchoredPosition = Vector2.zero;
        rect.sizeDelta = new Vector2(0, 80);

        var txt = new GameObject("Text");
        txt.transform.SetParent(go.transform, false);
        var tmp = txt.AddComponent<TextMeshProUGUI>();
        tmp.text = label;
        tmp.fontSize = 32;
        tmp.color = color;
        tmp.alignment = TextAlignmentOptions.Center;
        var tr = txt.GetComponent<RectTransform>();
        tr.anchorMin = Vector2.zero;
        tr.anchorMax = Vector2.one;
        tr.offsetMin = Vector2.zero;
        tr.offsetMax = Vector2.zero;
    }

    static void AddTag(string tag)
    {
        var asset = AssetDatabase.LoadMainAssetAtPath("ProjectSettings/TagManager.asset");
        if (asset == null) return;
        var so = new SerializedObject(asset);
        var tags = so.FindProperty("tags");
        for (int i = 0; i < tags.arraySize; i++)
            if (tags.GetArrayElementAtIndex(i).stringValue == tag) return;
        tags.InsertArrayElementAtIndex(tags.arraySize);
        tags.GetArrayElementAtIndex(tags.arraySize - 1).stringValue = tag;
        so.ApplyModifiedProperties();
    }

    static T EnsureComponent<T>(GameObject go) where T : Component
    {
        return go.GetComponent<T>() ?? go.AddComponent<T>();
    }
}
