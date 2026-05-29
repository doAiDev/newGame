using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using TMPro;
using System.IO;

public class NeonDriveSetup : EditorWindow
{
    [MenuItem("NeonDrive/게임 씨 자동 세팅")]
    public static void SetupScene()
    {
        if (EditorApplication.isPlaying)
        {
            EditorUtility.DisplayDialog("Neon Drive Setup", "플레이 모드를 먼저 종료하세요.", "확인");
            return;
        }
        if (!EditorUtility.DisplayDialog("Neon Drive Setup",
            "현재 씨을 Neon Drive 게임 씨으로 세팅합니다.",
            "세팅 시작", "취소"))
            return;

        AddTag("Traffic");
        AddTag("Coin");
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        EnsurePhysicalFolder(Application.dataPath + "/Textures");
        EnsurePhysicalFolder(Application.dataPath + "/Textures/Cars");

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

        DestroyIfExists("Road"); DestroyIfExists("Road2");
        CreateRoad("Road",  new Vector3(0,  0, 1));
        CreateRoad("Road2", new Vector3(0, 20, 1));

        float[] laneX = { -2.1f, -0.7f, 0.7f, 2.1f };
        for (int i = 0; i < laneX.Length; i++)
        {
            DestroyIfExists("Lane" + (i + 1));
            CreateLaneLine("Lane" + (i + 1), laneX[i]);
        }

        DestroyIfExists("Player");
        var player = new GameObject("Player");
        player.transform.position = new Vector3(0, -6, 0);
        var pSR = player.AddComponent<SpriteRenderer>();
        pSR.sprite = GetOrCreateCarSprite("car_player", new Color(0f, 1f, 0.78f), isPlayer: true);
        pSR.sortingOrder = 2;

        var pc = player.AddComponent<PlayerController>();
        pc.LaneWidth = 1.4f;
        pc.TotalLanes = 4;

        var rb = player.GetComponent<Rigidbody2D>();
        if (rb == null) rb = player.AddComponent<Rigidbody2D>();
        rb.gravityScale = 0f;
        rb.constraints = RigidbodyConstraints2D.FreezeRotation;

        var col = player.AddComponent<BoxCollider2D>();
        col.isTrigger = true;
        col.size = new Vector2(0.55f, 1.1f);

        if (GameObject.Find("TrafficSpawner") == null)
        { var ts = new GameObject("TrafficSpawner"); ts.AddComponent<TrafficSpawner>(); }
        if (GameObject.Find("CoinSpawner") == null)
        { var cs = new GameObject("CoinSpawner"); cs.AddComponent<CoinSpawner>(); }

        EnsureAssetFolder("Assets/Prefabs");
        var trafficPrefabs = CreateTrafficPrefabs();
        var coinPrefab     = CreateCoinPrefab();

        AssignTrafficPrefabs(trafficPrefabs);
        AssignCoinPrefab(coinPrefab);

        DestroyIfExists("Canvas");
        DestroyIfExists("EventSystem");
        SetupUI();

        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        EditorUtility.DisplayDialog("Neon Drive Setup",
            "✅ 세팅 완료!\nCtrl+S 저장 → WebGL 리빌드 → Push!",
            "확인");
    }

    // ===== 차량 스프라이트 =====

    static Sprite GetOrCreateCarSprite(string name, Color body, bool isPlayer = false)
    {
        string assetPath = $"Assets/Textures/Cars/{name}.png";
        var tex = CreateCarTexture(body, isPlayer);
        string fullPath = Path.Combine(Application.dataPath, "Textures", "Cars", $"{name}.png");
        File.WriteAllBytes(fullPath, tex.EncodeToPNG());
        Object.DestroyImmediate(tex);
        AssetDatabase.ImportAsset(assetPath);
        var ti = AssetImporter.GetAtPath(assetPath) as TextureImporter;
        if (ti != null)
        {
            ti.textureType = TextureImporterType.Sprite;
            ti.spritePivot = new Vector2(0.5f, 0.5f);
            ti.spritePixelsPerUnit = 43;
            ti.filterMode = FilterMode.Point;
            ti.textureCompression = TextureImporterCompression.Uncompressed;
            AssetDatabase.ImportAsset(assetPath);
        }
        return AssetDatabase.LoadAssetAtPath<Sprite>(assetPath);
    }

    static Texture2D CreateCarTexture(Color body, bool isPlayer)
    {
        int w = 32, h = 56;
        var px = new Color[w * h];
        Color wheel = new Color(0.12f, 0.12f, 0.12f);
        Color glass = new Color(0.35f, 0.62f, 0.82f, 0.88f);
        Color hlamp = new Color(1f, 0.97f, 0.7f);
        Color tlamp = new Color(1f, 0.12f, 0.12f);
        Color lo    = Darken(body, 0.6f);
        Color hi    = Lighten(body, 1.3f);
        Color roof  = Darken(body, 0.5f);
        Color rim   = new Color(0.35f, 0.35f, 0.35f);

        void S(int x, int y, Color c) { if (x>=0&&x<w&&y>=0&&y<h) px[y*w+x]=c; }
        void R(int x, int y, int rw, int rh, Color c) { for(int j=y;j<y+rh;j++) for(int i=x;i<x+rw;i++) S(i,j,c); }

        R(0,41,7,13,wheel); R(25,41,7,13,wheel); R(0,2,7,13,wheel); R(25,2,7,13,wheel);
        R(1,42,5,11,rim);   R(26,42,5,11,rim);   R(1,3,5,11,rim);  R(26,3,5,11,rim);
        S(3,47,wheel); S(28,47,wheel); S(3,8,wheel); S(28,8,wheel);
        R(4,1,24,54,body);
        R(5,44,22,10,hi);
        R(15,44,2,10,Darken(hi,0.82f));
        R(6,35,20,10,glass);
        S(6,35,lo); S(25,35,lo); S(6,44,lo); S(25,44,lo);
        R(5,20,22,15,roof);
        R(4,20,2,15,glass); R(26,20,2,15,glass);
        R(6,11,20,8,glass);
        S(6,11,lo); S(25,11,lo); S(6,18,lo); S(25,18,lo);
        R(5,2,22,9,lo);
        if (isPlayer) { R(9,19,14,3,Darken(body,0.4f)); R(10,18,12,2,Darken(body,0.35f)); }
        R(5,53,9,2,hlamp); R(18,53,9,2,hlamp);
        R(5,1,9,2,tlamp);  R(18,1,9,2,tlamp);
        for(int j=1;j<h-1;j++){S(4,j,lo);S(27,j,lo);}

        var t = new Texture2D(w, h, TextureFormat.RGBA32, false);
        t.filterMode = FilterMode.Point;
        t.SetPixels(px); t.Apply();
        return t;
    }

    static Color Darken(Color c, float f)  => new Color(c.r*f, c.g*f, c.b*f, c.a);
    static Color Lighten(Color c, float f) => new Color(Mathf.Min(1f,c.r*f), Mathf.Min(1f,c.g*f), Mathf.Min(1f,c.b*f), c.a);

    // ===== 도로 =====

    static void CreateRoad(string name, Vector3 pos)
    {
        var road = CreateRectSprite(name, pos, new Vector3(5.8f,20f,1f), new Color(0.18f,0.18f,0.28f));
        road.AddComponent<RoadScroller>();
    }

    static void CreateLaneLine(string name, float x)
    {
        var line = CreateRectSprite(name, new Vector3(x,0,0.5f), new Vector3(0.06f,20f,1f), new Color(0.6f,0.3f,1f,0.35f));
        line.AddComponent<RoadScroller>();
    }

    static GameObject CreateRectSprite(string name, Vector3 pos, Vector3 scale, Color color)
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
        const string ap = "Assets/Textures/white_square.png";
        if (AssetDatabase.LoadAssetAtPath<Sprite>(ap) != null) return AssetDatabase.LoadAssetAtPath<Sprite>(ap);
        var tex = new Texture2D(4,4,TextureFormat.RGBA32,false);
        var p = new Color[16]; for(int i=0;i<16;i++) p[i]=Color.white;
        tex.SetPixels(p); tex.Apply();
        string full = Path.Combine(Application.dataPath,"Textures","white_square.png");
        Directory.CreateDirectory(Path.GetDirectoryName(full));
        File.WriteAllBytes(full,tex.EncodeToPNG());
        AssetDatabase.ImportAsset(ap);
        var ti = AssetImporter.GetAtPath(ap) as TextureImporter;
        if(ti!=null){ti.textureType=TextureImporterType.Sprite;AssetDatabase.ImportAsset(ap);}
        return AssetDatabase.LoadAssetAtPath<Sprite>(ap);
    }

    static Sprite GetOrCreateCircleSprite()
    {
        const string ap = "Assets/Textures/white_circle.png";
        if (AssetDatabase.LoadAssetAtPath<Sprite>(ap) != null) return AssetDatabase.LoadAssetAtPath<Sprite>(ap);
        const int sz=64;
        var tex=new Texture2D(sz,sz,TextureFormat.RGBA32,false);
        float c2=sz/2f-0.5f,r=sz/2f-1f;
        for(int y=0;y<sz;y++) for(int x=0;x<sz;x++){float dx=x-c2,dy=y-c2;tex.SetPixel(x,y,Mathf.Sqrt(dx*dx+dy*dy)<=r?Color.white:Color.clear);}
        tex.Apply();
        string full=Path.Combine(Application.dataPath,"Textures","white_circle.png");
        Directory.CreateDirectory(Path.GetDirectoryName(full));
        File.WriteAllBytes(full,tex.EncodeToPNG());
        AssetDatabase.ImportAsset(ap);
        var ti=AssetImporter.GetAtPath(ap) as TextureImporter;
        if(ti!=null){ti.textureType=TextureImporterType.Sprite;AssetDatabase.ImportAsset(ap);}
        return AssetDatabase.LoadAssetAtPath<Sprite>(ap);
    }

    // ===== 프리팩 =====

    static readonly Color[] TrafficColors = {
        new Color(1f,0.18f,0.3f),
        new Color(0.2f,0.5f,1f),
        new Color(1f,0.85f,0.1f),
    };

    static GameObject[] CreateTrafficPrefabs()
    {
        var prefabs = new GameObject[TrafficColors.Length];
        for(int i=0;i<TrafficColors.Length;i++)
        {
            string path = $"Assets/Prefabs/TrafficCar{i+1}.prefab";
            var go = new GameObject($"TrafficCar{i+1}");
            var sr = go.AddComponent<SpriteRenderer>();
            sr.sprite = GetOrCreateCarSprite($"car_traffic_{i+1}", TrafficColors[i]);
            sr.sortingOrder = 1;
            go.AddComponent<TrafficCar>();
            var c = go.AddComponent<BoxCollider2D>();
            c.isTrigger = true; c.size = new Vector2(0.55f,1.1f);
            var prefab = PrefabUtility.SaveAsPrefabAsset(go, path);
            Object.DestroyImmediate(go);
            if(prefab!=null) prefab.tag="Traffic";
            EditorUtility.SetDirty(prefab);
            prefabs[i]=prefab;
        }
        AssetDatabase.SaveAssets();
        return prefabs;
    }

    static GameObject CreateCoinPrefab()
    {
        const string path="Assets/Prefabs/Coin.prefab";
        var go=new GameObject("Coin");
        go.transform.localScale=new Vector3(0.6f,0.6f,1f);
        var sr=go.AddComponent<SpriteRenderer>();
        sr.sprite=GetOrCreateCircleSprite(); sr.color=new Color(1f,0.84f,0f);
        go.AddComponent<CoinController>();
        var c=go.AddComponent<CircleCollider2D>(); c.isTrigger=true;
        var prefab=PrefabUtility.SaveAsPrefabAsset(go,path);
        Object.DestroyImmediate(go);
        if(prefab!=null) prefab.tag="Coin";
        EditorUtility.SetDirty(prefab); AssetDatabase.SaveAssets();
        return prefab;
    }

    static void AssignTrafficPrefabs(GameObject[] prefabs)
    {
        var spawner=Object.FindObjectOfType<TrafficSpawner>(); if(spawner==null) return;
        var so=new SerializedObject(spawner);
        var prop=so.FindProperty("CarPrefabs");
        prop.arraySize=prefabs.Length;
        for(int i=0;i<prefabs.Length;i++) prop.GetArrayElementAtIndex(i).objectReferenceValue=prefabs[i];
        so.ApplyModifiedProperties(); EditorUtility.SetDirty(spawner);
    }

    static void AssignCoinPrefab(GameObject prefab)
    {
        if(prefab==null) return;
        var spawner=Object.FindObjectOfType<CoinSpawner>(); if(spawner==null) return;
        var so=new SerializedObject(spawner);
        so.FindProperty("CoinPrefab").objectReferenceValue=prefab;
        so.ApplyModifiedProperties(); EditorUtility.SetDirty(spawner);
    }

    // ===== UI =====

    static void SetupUI()
    {
        // EventSystem - 터치/클릭 이벤트에 필수
        var esGO = new GameObject("EventSystem");
        esGO.AddComponent<EventSystem>();
        esGO.AddComponent<StandaloneInputModule>();

        var canvasGO=new GameObject("Canvas");
        var canvas=canvasGO.AddComponent<Canvas>();
        canvas.renderMode=RenderMode.ScreenSpaceOverlay;
        var scaler=canvasGO.AddComponent<CanvasScaler>();
        scaler.uiScaleMode=CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution=new Vector2(1080,1920);
        canvasGO.AddComponent<GraphicRaycaster>();

        var hud=new GameObject("HUD");
        hud.transform.SetParent(canvasGO.transform,false);
        SetFullStretch(hud);

        var coinsGO=MakeTMPText(hud,"CoinsText","0",new Vector2(0.5f,1f),new Vector2(0,-100),40,Color.yellow);
        var distGO=MakeTMPText(hud,"DistanceText","0.0 km",new Vector2(1f,1f),new Vector2(-50,-100),32,new Color(0f,1f,0.78f));

        var heartsGO=new GameObject("Hearts");
        heartsGO.transform.SetParent(hud.transform,false);
        var hr=heartsGO.AddComponent<RectTransform>();
        hr.anchorMin=hr.anchorMax=new Vector2(0f,1f);
        hr.anchoredPosition=new Vector2(60,-90); hr.sizeDelta=new Vector2(150,50);
        var hlg=heartsGO.AddComponent<HorizontalLayoutGroup>();
        hlg.spacing=8; hlg.childControlWidth=hlg.childControlHeight=false;

        var heartImages=new Image[3];
        for(int i=0;i<3;i++)
        {
            var h=new GameObject("Heart"+(i+1));
            h.transform.SetParent(heartsGO.transform,false);
            var img=h.AddComponent<Image>(); img.color=new Color(1f,0.18f,0.47f);
            h.GetComponent<RectTransform>().sizeDelta=new Vector2(44,44);
            heartImages[i]=img;
        }

        var goPanel=MakePanel(canvasGO,"GameOverPanel",new Color(0.027f,0.027f,0.078f,0.95f));
        MakeTMPText(goPanel,"CrashText","CRASH!",new Vector2(0.5f,0.65f),Vector2.zero,80,new Color(1f,0.18f,0.47f));
        var goCoinsGO=MakeTMPText(goPanel,"GOCoinsText","0",new Vector2(0.5f,0.52f),Vector2.zero,44,Color.yellow);
        var goDistGO=MakeTMPText(goPanel,"GODistText","0.00 km",new Vector2(0.5f,0.44f),Vector2.zero,44,new Color(0f,1f,0.78f));
        MakeButton(goPanel,"ReviveBtn","REVIVE",new Vector2(0.5f,0.32f),new Color(0f,1f,0.78f));
        MakeButton(goPanel,"RetryBtn","RETRY",new Vector2(0.5f,0.22f),new Color(0.47f,0.18f,1f));
        MakeButton(goPanel,"HomeBtn","HOME",new Vector2(0.5f,0.12f),new Color(0.4f,0.4f,0.5f));
        goPanel.SetActive(false);

        var pausePanel=MakePanel(canvasGO,"PausePanel",new Color(0.027f,0.027f,0.078f,0.92f));
        MakeTMPText(pausePanel,"PauseTitle","PAUSED",new Vector2(0.5f,0.6f),Vector2.zero,80,new Color(0f,1f,0.78f));
        MakeButton(pausePanel,"ResumeBtn","RESUME",new Vector2(0.5f,0.45f),new Color(0f,1f,0.78f));
        MakeButton(pausePanel,"PauseHomeBtn","HOME",new Vector2(0.5f,0.33f),new Color(0.4f,0.4f,0.5f));
        pausePanel.SetActive(false);

        // 조이스틱
        var jGO=new GameObject("Joystick");
        jGO.transform.SetParent(canvasGO.transform,false);
        var jRect=jGO.AddComponent<RectTransform>();
        jRect.anchorMin=jRect.anchorMax=new Vector2(0.5f,0f);
        jRect.anchoredPosition=new Vector2(0,200);
        jRect.sizeDelta=new Vector2(300,300);

        var bgGO=new GameObject("Background");
        bgGO.transform.SetParent(jGO.transform,false);
        var bgImg=bgGO.AddComponent<Image>(); bgImg.color=new Color(1f,1f,1f,0.12f);
        var bgRect=bgGO.GetComponent<RectTransform>();
        bgRect.anchorMin=Vector2.zero; bgRect.anchorMax=Vector2.one;
        bgRect.offsetMin=bgRect.offsetMax=Vector2.zero;

        var hGO=new GameObject("Handle");
        hGO.transform.SetParent(jGO.transform,false);
        var hImg=hGO.AddComponent<Image>(); hImg.color=new Color(0f,1f,0.78f,0.7f);
        var hRect=hGO.GetComponent<RectTransform>();
        hRect.anchorMin=hRect.anchorMax=new Vector2(0.5f,0.5f);
        hRect.sizeDelta=new Vector2(100,100); hRect.anchoredPosition=Vector2.zero;

        var joystick=jGO.AddComponent<Joystick>();
        joystick.Background=bgRect; joystick.Handle=hRect; joystick.HorizontalOnly=true;

        var uiGO=new GameObject("UIManager");
        uiGO.transform.SetParent(canvasGO.transform,false);
        var uiMgr=uiGO.AddComponent<UIManager>();
        var so2=new SerializedObject(uiMgr);
        so2.FindProperty("CoinsText").objectReferenceValue=coinsGO.GetComponent<TextMeshProUGUI>();
        so2.FindProperty("DistanceText").objectReferenceValue=distGO.GetComponent<TextMeshProUGUI>();
        so2.FindProperty("GameOverPanel").objectReferenceValue=goPanel;
        so2.FindProperty("GOCoinsText").objectReferenceValue=goCoinsGO.GetComponent<TextMeshProUGUI>();
        so2.FindProperty("GODistanceText").objectReferenceValue=goDistGO.GetComponent<TextMeshProUGUI>();
        so2.FindProperty("PausePanel").objectReferenceValue=pausePanel;
        var hp=so2.FindProperty("HeartIcons");
        hp.arraySize=heartImages.Length;
        for(int i=0;i<heartImages.Length;i++) hp.GetArrayElementAtIndex(i).objectReferenceValue=heartImages[i];
        so2.ApplyModifiedProperties(); EditorUtility.SetDirty(uiMgr);
    }

    // ===== UI 헬퍼 =====

    static GameObject MakePanel(GameObject parent,string name,Color color)
    {
        var go=new GameObject(name); go.transform.SetParent(parent.transform,false);
        go.AddComponent<Image>().color=color; SetFullStretch(go); return go;
    }

    static GameObject MakeTMPText(GameObject parent,string name,string text,Vector2 anchor,Vector2 pos,float size,Color color)
    {
        var go=new GameObject(name); go.transform.SetParent(parent.transform,false);
        var tmp=go.AddComponent<TextMeshProUGUI>();
        tmp.text=text; tmp.fontSize=size; tmp.color=color;
        tmp.alignment=TextAlignmentOptions.Center;
        var r=go.GetComponent<RectTransform>();
        r.anchorMin=r.anchorMax=anchor; r.anchoredPosition=pos; r.sizeDelta=new Vector2(500,70);
        return go;
    }

    static void MakeButton(GameObject parent,string name,string label,Vector2 anchor,Color color)
    {
        var go=new GameObject(name); go.transform.SetParent(parent.transform,false);
        go.AddComponent<Image>().color=new Color(color.r*.1f,color.g*.1f,color.b*.1f,.9f);
        go.AddComponent<Button>();
        var r=go.GetComponent<RectTransform>();
        r.anchorMin=new Vector2(anchor.x-.22f,anchor.y); r.anchorMax=new Vector2(anchor.x+.22f,anchor.y);
        r.anchoredPosition=Vector2.zero; r.sizeDelta=new Vector2(0,90);
        var tgo=new GameObject("Label"); tgo.transform.SetParent(go.transform,false);
        var tmp=tgo.AddComponent<TextMeshProUGUI>();
        tmp.text=label; tmp.fontSize=36; tmp.color=color; tmp.alignment=TextAlignmentOptions.Center;
        var tr=tgo.GetComponent<RectTransform>();
        tr.anchorMin=Vector2.zero; tr.anchorMax=Vector2.one; tr.offsetMin=tr.offsetMax=Vector2.zero;
    }

    static void SetFullStretch(GameObject go)
    {
        var r=go.GetComponent<RectTransform>();
        if(r==null) r=go.AddComponent<RectTransform>();
        r.anchorMin=Vector2.zero; r.anchorMax=Vector2.one; r.offsetMin=r.offsetMax=Vector2.zero;
    }

    static void DestroyIfExists(string name)
    { var e=GameObject.Find(name); if(e!=null) Object.DestroyImmediate(e); }

    static void EnsureAssetFolder(string path)
    {
        if(!AssetDatabase.IsValidFolder(path))
        { var parts=path.Split('/'); AssetDatabase.CreateFolder(parts[0],parts[1]); }
    }

    static void EnsurePhysicalFolder(string abs)
    { if(!Directory.Exists(abs)) Directory.CreateDirectory(abs); }

    static void AddTag(string tag)
    {
        var asset=AssetDatabase.LoadMainAssetAtPath("ProjectSettings/TagManager.asset");
        if(asset==null) return;
        var so=new SerializedObject(asset);
        var tags=so.FindProperty("tags");
        for(int i=0;i<tags.arraySize;i++) if(tags.GetArrayElementAtIndex(i).stringValue==tag) return;
        int idx=tags.arraySize;
        tags.InsertArrayElementAtIndex(idx);
        tags.GetArrayElementAtIndex(idx).stringValue=tag;
        so.ApplyModifiedProperties();
    }
}
