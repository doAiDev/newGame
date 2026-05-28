using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.UI;
using TMPro;
using System.IO;

public class NeonDriveSetup : EditorWindow
{
    [MenuItem("NeonDrive/게임 씨 자동 세팅")]
    public static void SetupScene()
    {
        if (!EditorUtility.DisplayDialog("Neon Drive Setup",
            "현재 씨을 Neon Drive 게임 씨으로 세팅합니다.",
            "세팅 시작", "취소"))
            return;

        AddTag("Traffic");
        AddTag("Coin");
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        EnsurePhysicalFolder(Application.dataPath + "/Textures");

        var cam = Camera.main;
        if (cam != null)
        {
            cam.orthographic = true;
            cam.orthographicSize = 10;
            cam.transform.position = new Vector3(0, 0, -10);
            cam.backgroundColor = new Color(0.027f, 0.027f, 0.078f);
            cam.clearFlags = CameraClearFlags.SolidColor;
            if (cam.GetComponent<CameraShake>() == null)
                cam.gameObject.AddComponent<CameraShake>();
        }

        if (GameObject.Find("GameManager") == null)
        {
            var gm = new GameObject("GameManager");
            gm.AddComponent<GameManager>();
        }

        DestroyIfExists("Road");
        DestroyIfExists("Road2");
        CreateRoad("Road",  new Vector3(0,  0, 1));
        CreateRoad("Road2", new Vector3(0, 20, 1));

        float[] laneX = { -2.1f, -0.7f, 0.7f, 2.1f };
        for (int i = 0; i < laneX.Length; i++)
        {
            DestroyIfExists("Lane" + (i + 1));
            CreateLaneLine("Lane" + (i + 1), laneX[i]);
        }

        DestroyIfExists("Player");
        var player = CreateSquareSprite("Player",
            new Vector3(0, -6, 0),
            new Vector3(0.75f, 1.3f, 1f),
            new Color(0f, 1f, 0.78f));

        var pc = player.AddComponent<PlayerController>();
        pc.LaneWidth = 1.4f;
        pc.TotalLanes = 4;

        var rb = player.GetComponent<Rigidbody2D>();
        if (rb == null) rb = player.AddComponent<Rigidbody2D>();
        rb.gravityScale = 0f;
        rb.constraints = RigidbodyConstraints2D.FreezeRotation;

        var col = player.AddComponent<BoxCollider2D>();
        col.isTrigger = true;

        if (GameObject.Find("TrafficSpawner") == null)
        {
            var ts = new GameObject("TrafficSpawner");
            ts.AddComponent<TrafficSpawner>();
        }
        if (GameObject.Find("CoinSpawner") == null)
        {
            var cs = new GameObject("CoinSpawner");
            cs.AddComponent<CoinSpawner>();
        }

        EnsureAssetFolder("Assets/Prefabs");
        CreateTrafficPrefab();
        CreateCoinPrefab();

        DestroyIfExists("Canvas");
        SetupUI();

        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        EditorUtility.DisplayDialog("Neon Drive Setup",
            "✅ 세팅 완료!\nCtrl+S 로 저장하고 플레이 버튼을 눌러보세요!",
            "확인");
    }

    // -------------------------------------------------------

    static void CreateRoad(string name, Vector3 pos)
    {
        var road = CreateSquareSprite(name, pos,
            new Vector3(5.8f, 20f, 1f), new Color(0.1f, 0.1f, 0.18f));
        road.AddComponent<RoadScroller>();
    }

    static void CreateLaneLine(string name, float x)
    {
        var line = CreateSquareSprite(name, new Vector3(x, 0, 0.5f),
            new Vector3(0.03f, 20f, 1f), new Color(0.47f, 0.18f, 1f, 0.25f));
        line.AddComponent<RoadScroller>();
    }

    static GameObject CreateSquareSprite(string name, Vector3 pos, Vector3 scale, Color color)
    {
        var go = new GameObject(name);
        go.transform.position = pos;
        go.transform.localScale = scale;
        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = GetOrCreateWhiteSprite();
        sr.color = color;
        return go;
    }

    static Sprite GetOrCreateWhiteSprite()
    {
        const string assetPath = "Assets/Textures/white_square.png";
        var existing = AssetDatabase.LoadAssetAtPath<Sprite>(assetPath);
        if (existing != null) return existing;

        var tex = new Texture2D(4, 4, TextureFormat.RGBA32, false);
        var pixels = new Color[16];
        for (int i = 0; i < 16; i++) pixels[i] = Color.white;
        tex.SetPixels(pixels);
        tex.Apply();

        string fullPath = Path.Combine(Application.dataPath, "Textures", "white_square.png");
        Directory.CreateDirectory(Path.GetDirectoryName(fullPath));
        File.WriteAllBytes(fullPath, tex.EncodeToPNG());
        AssetDatabase.ImportAsset(assetPath);

        var ti = AssetImporter.GetAtPath(assetPath) as TextureImporter;
        if (ti != null) { ti.textureType = TextureImporterType.Sprite; AssetDatabase.ImportAsset(assetPath); }
        return AssetDatabase.LoadAssetAtPath<Sprite>(assetPath);
    }

    static Sprite GetOrCreateCircleSprite()
    {
        const string assetPath = "Assets/Textures/white_circle.png";
        var existing = AssetDatabase.LoadAssetAtPath<Sprite>(assetPath);
        if (existing != null) return existing;

        const int size = 64;
        var tex = new Texture2D(size, size, TextureFormat.RGBA32, false);
        float center = size / 2f - 0.5f;
        float radius = size / 2f - 1f;
        for (int y = 0; y < size; y++)
            for (int x = 0; x < size; x++)
            {
                float dx = x - center, dy = y - center;
                tex.SetPixel(x, y, Mathf.Sqrt(dx * dx + dy * dy) <= radius ? Color.white : Color.clear);
            }
        tex.Apply();

        string fullPath = Path.Combine(Application.dataPath, "Textures", "white_circle.png");
        Directory.CreateDirectory(Path.GetDirectoryName(fullPath));
        File.WriteAllBytes(fullPath, tex.EncodeToPNG());
        AssetDatabase.ImportAsset(assetPath);

        var ti = AssetImporter.GetAtPath(assetPath) as TextureImporter;
        if (ti != null) { ti.textureType = TextureImporterType.Sprite; AssetDatabase.ImportAsset(assetPath); }
        return AssetDatabase.LoadAssetAtPath<Sprite>(assetPath);
    }

    static void CreateTrafficPrefab()
    {
        const string path = "Assets/Prefabs/TrafficCar.prefab";
        var go = new GameObject("TrafficCar");
        go.transform.localScale = new Vector3(0.75f, 1.3f, 1f);
        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = GetOrCreateWhiteSprite();
        sr.color = new Color(1f, 0.18f, 0.47f);
        go.AddComponent<TrafficCar>();
        var c = go.AddComponent<BoxCollider2D>();
        c.isTrigger = true;

        PrefabUtility.SaveAsPrefabAsset(go, path);
        Object.DestroyImmediate(go);

        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
        if (prefab != null) prefab.tag = "Traffic";
        EditorUtility.SetDirty(prefab);
        AssetDatabase.SaveAssets();

        var spawner = Object.FindObjectOfType<TrafficSpawner>();
        if (spawner != null) spawner.CarPrefabs = new GameObject[] { prefab };
    }

    static void CreateCoinPrefab()
    {
        const string path = "Assets/Prefabs/Coin.prefab";
        var go = new GameObject("Coin");
        go.transform.localScale = new Vector3(0.6f, 0.6f, 1f);
        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = GetOrCreateCircleSprite();
        sr.color = new Color(1f, 0.84f, 0f);
        go.AddComponent<CoinController>();
        var c = go.AddComponent<CircleCollider2D>();
        c.isTrigger = true;

        PrefabUtility.SaveAsPrefabAsset(go, path);
        Object.DestroyImmediate(go);

        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
        if (prefab != null) prefab.tag = "Coin";
        EditorUtility.SetDirty(prefab);
        AssetDatabase.SaveAssets();

        var spawner = Object.FindObjectOfType<CoinSpawner>();
        if (spawner != null) spawner.CoinPrefab = prefab;
    }

    static void SetupUI()
    {
        var canvasGO = new GameObject("Canvas");
        var canvas = canvasGO.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        var scaler = canvasGO.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1080, 1920);
        canvasGO.AddComponent<GraphicRaycaster>();

        // HUD
        var hud = new GameObject("HUD");
        hud.transform.SetParent(canvasGO.transform, false);
        SetFullStretch(hud);

        var coinsGO = MakeTMPText(hud, "CoinsText",    "0",      new Vector2(0.5f, 1f), new Vector2(0, -100),   40, Color.yellow);
        var distGO  = MakeTMPText(hud, "DistanceText", "0.0 km", new Vector2(1f,   1f), new Vector2(-50, -100), 32, new Color(0f, 1f, 0.78f));

        var heartsGO = new GameObject("Hearts");
        heartsGO.transform.SetParent(hud.transform, false);
        var hr = heartsGO.AddComponent<RectTransform>();
        hr.anchorMin = hr.anchorMax = new Vector2(0f, 1f);
        hr.anchoredPosition = new Vector2(60, -90);
        hr.sizeDelta = new Vector2(150, 50);
        var hlg = heartsGO.AddComponent<HorizontalLayoutGroup>();
        hlg.spacing = 8;
        hlg.childControlWidth = hlg.childControlHeight = false;

        var heartImages = new Image[3];
        for (int i = 0; i < 3; i++)
        {
            var h = new GameObject("Heart" + (i + 1));
            h.transform.SetParent(heartsGO.transform, false);
            var img = h.AddComponent<Image>();
            img.color = new Color(1f, 0.18f, 0.47f);
            h.GetComponent<RectTransform>().sizeDelta = new Vector2(44, 44);
            heartImages[i] = img;
        }

        // GameOver Panel
        var goPanel = MakePanel(canvasGO, "GameOverPanel", new Color(0.027f, 0.027f, 0.078f, 0.95f));
        MakeTMPText(goPanel, "CrashText",   "CRASH!",  new Vector2(0.5f, 0.65f), Vector2.zero, 80, new Color(1f, 0.18f, 0.47f));
        var goCoinsGO = MakeTMPText(goPanel, "GOCoinsText", "0",       new Vector2(0.5f, 0.52f), Vector2.zero, 44, Color.yellow);
        var goDistGO  = MakeTMPText(goPanel, "GODistText",  "0.00 km", new Vector2(0.5f, 0.44f), Vector2.zero, 44, new Color(0f, 1f, 0.78f));
        MakeButton(goPanel, "ReviveBtn", "REVIVE", new Vector2(0.5f, 0.32f), new Color(0f, 1f, 0.78f));
        MakeButton(goPanel, "RetryBtn",  "RETRY",  new Vector2(0.5f, 0.22f), new Color(0.47f, 0.18f, 1f));
        MakeButton(goPanel, "HomeBtn",   "HOME",   new Vector2(0.5f, 0.12f), new Color(0.4f, 0.4f, 0.5f));
        goPanel.SetActive(false);

        // Pause Panel
        var pausePanel = MakePanel(canvasGO, "PausePanel", new Color(0.027f, 0.027f, 0.078f, 0.92f));
        MakeTMPText(pausePanel, "PauseTitle", "PAUSED", new Vector2(0.5f, 0.6f), Vector2.zero, 80, new Color(0f, 1f, 0.78f));
        MakeButton(pausePanel, "ResumeBtn", "RESUME", new Vector2(0.5f, 0.45f), new Color(0f, 1f, 0.78f));
        MakeButton(pausePanel, "PauseHomeBtn", "HOME", new Vector2(0.5f, 0.33f), new Color(0.4f, 0.4f, 0.5f));
        pausePanel.SetActive(false);

        // Joystick
        var jGO = new GameObject("Joystick");
        jGO.transform.SetParent(canvasGO.transform, false);
        var jRect = jGO.AddComponent<RectTransform>();
        jRect.anchorMin = jRect.anchorMax = new Vector2(0.5f, 0f);
        jRect.anchoredPosition = new Vector2(0, 140);
        jRect.sizeDelta = new Vector2(220, 220);

        var bgGO = new GameObject("Background");
        bgGO.transform.SetParent(jGO.transform, false);
        var bgImg = bgGO.AddComponent<Image>();
        bgImg.color = new Color(1f, 1f, 1f, 0.07f);
        var bgRect = bgGO.GetComponent<RectTransform>();
        bgRect.anchorMin = Vector2.zero;
        bgRect.anchorMax = Vector2.one;
        bgRect.offsetMin = bgRect.offsetMax = Vector2.zero;

        var hGO = new GameObject("Handle");
        hGO.transform.SetParent(jGO.transform, false);
        var hImg = hGO.AddComponent<Image>();
        hImg.color = new Color(0f, 1f, 0.78f, 0.55f);
        var hRect = hGO.GetComponent<RectTransform>();
        hRect.anchorMin = hRect.anchorMax = new Vector2(0.5f, 0.5f);
        hRect.sizeDelta = new Vector2(75, 75);
        hRect.anchoredPosition = Vector2.zero;

        var joystick = jGO.AddComponent<Joystick>();
        joystick.Background = bgRect;
        joystick.Handle = hRect;
        joystick.HorizontalOnly = true;

        // UIManager
        var uiGO = new GameObject("UIManager");
        uiGO.transform.SetParent(canvasGO.transform, false);
        var uiMgr = uiGO.AddComponent<UIManager>();
        uiMgr.CoinsText      = coinsGO.GetComponent<TextMeshProUGUI>();
        uiMgr.DistanceText   = distGO.GetComponent<TextMeshProUGUI>();
        uiMgr.HeartIcons     = heartImages;
        uiMgr.GameOverPanel  = goPanel;
        uiMgr.GOCoinsText    = goCoinsGO.GetComponent<TextMeshProUGUI>();
        uiMgr.GODistanceText = goDistGO.GetComponent<TextMeshProUGUI>();
        uiMgr.PausePanel     = pausePanel;
    }

    // -------------------------------------------------------
    // 헬퍼

    static GameObject MakePanel(GameObject parent, string name, Color color)
    {
        var go = new GameObject(name);
        go.transform.SetParent(parent.transform, false);
        go.AddComponent<Image>().color = color;
        SetFullStretch(go);
        return go;
    }

    static GameObject MakeTMPText(GameObject parent, string name, string text,
        Vector2 anchor, Vector2 pos, float size, Color color)
    {
        var go = new GameObject(name);
        go.transform.SetParent(parent.transform, false);
        var tmp = go.AddComponent<TextMeshProUGUI>();
        tmp.text = text;
        tmp.fontSize = size;
        tmp.color = color;
        tmp.alignment = TextAlignmentOptions.Center;
        var r = go.GetComponent<RectTransform>();
        r.anchorMin = r.anchorMax = anchor;
        r.anchoredPosition = pos;
        r.sizeDelta = new Vector2(500, 70);
        return go;
    }

    static void MakeButton(GameObject parent, string name, string label,
        Vector2 anchor, Color color)
    {
        var go = new GameObject(name);
        go.transform.SetParent(parent.transform, false);
        go.AddComponent<Image>().color = new Color(color.r * 0.1f, color.g * 0.1f, color.b * 0.1f, 0.9f);
        go.AddComponent<Button>();
        var r = go.GetComponent<RectTransform>();
        r.anchorMin = new Vector2(anchor.x - 0.22f, anchor.y);
        r.anchorMax = new Vector2(anchor.x + 0.22f, anchor.y);
        r.anchoredPosition = Vector2.zero;
        r.sizeDelta = new Vector2(0, 90);

        var tgo = new GameObject("Label");
        tgo.transform.SetParent(go.transform, false);
        var tmp = tgo.AddComponent<TextMeshProUGUI>();
        tmp.text = label;
        tmp.fontSize = 36;
        tmp.color = color;
        tmp.alignment = TextAlignmentOptions.Center;
        var tr = tgo.GetComponent<RectTransform>();
        tr.anchorMin = Vector2.zero;
        tr.anchorMax = Vector2.one;
        tr.offsetMin = tr.offsetMax = Vector2.zero;
    }

    static void SetFullStretch(GameObject go)
    {
        var r = go.GetComponent<RectTransform>();
        if (r == null) r = go.AddComponent<RectTransform>();
        r.anchorMin = Vector2.zero;
        r.anchorMax = Vector2.one;
        r.offsetMin = r.offsetMax = Vector2.zero;
    }

    static void DestroyIfExists(string name)
    {
        var existing = GameObject.Find(name);
        if (existing != null) Object.DestroyImmediate(existing);
    }

    static void EnsureAssetFolder(string path)
    {
        if (!AssetDatabase.IsValidFolder(path))
        {
            var parts = path.Split('/');
            AssetDatabase.CreateFolder(parts[0], parts[1]);
        }
    }

    static void EnsurePhysicalFolder(string absolutePath)
    {
        if (!Directory.Exists(absolutePath))
            Directory.CreateDirectory(absolutePath);
    }

    static void AddTag(string tag)
    {
        var asset = AssetDatabase.LoadMainAssetAtPath("ProjectSettings/TagManager.asset");
        if (asset == null) return;
        var so = new SerializedObject(asset);
        var tags = so.FindProperty("tags");
        for (int i = 0; i < tags.arraySize; i++)
            if (tags.GetArrayElementAtIndex(i).stringValue == tag) return;
        int idx = tags.arraySize;
        tags.InsertArrayElementAtIndex(idx);
        tags.GetArrayElementAtIndex(idx).stringValue = tag;
        so.ApplyModifiedProperties();
    }
}
