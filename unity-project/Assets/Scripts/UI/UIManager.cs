using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UIManager : MonoBehaviour
{
    [Header("Home")]
    public GameObject HomePanel;
    public GameObject ShopPanel;

    [Header("HUD")]
    public TextMeshProUGUI CoinsText;
    public TextMeshProUGUI DistanceText;
    public Image[] HeartIcons;
    public Color HeartActiveColor   = new Color(1f, 0.18f, 0.47f);
    public Color HeartInactiveColor = new Color(0.2f, 0.2f, 0.3f);

    [Header("Panels")]
    public GameObject HUD;
    public GameObject GameOverPanel;
    public TextMeshProUGUI GOCoinsText;
    public TextMeshProUGUI GODistanceText;
    public GameObject PausePanel;

    void Start()
    {
        if (GameManager.Instance == null) { Debug.LogError("[UIManager] GameManager missing"); return; }

        GameManager.Instance.OnGameStarted  += OnGameStarted;
        GameManager.Instance.OnStatsUpdate  += UpdateStats;
        GameManager.Instance.OnGameOver     += ShowGameOver;
        GameManager.Instance.OnLivesChanged += UpdateLives;

        // Wire buttons by name
        WireButton("StartBtn",    OnStartGame);
        WireButton("ShopBtn",     OnShop);
        WireButton("CloseShopBtn",OnCloseShop);
        WireButton("PauseBtn",    OnPause);
        WireButton("ReviveBtn",   OnRevive);
        WireButton("RetryBtn",    OnRestart);
        WireButton("HomeBtn",     OnHome);
        WireButton("ResumeBtn",   OnResume);
        WireButton("PauseHomeBtn",OnHome);

        ShowHome();
    }

    void OnDestroy()
    {
        if (GameManager.Instance == null) return;
        GameManager.Instance.OnGameStarted  -= OnGameStarted;
        GameManager.Instance.OnStatsUpdate  -= UpdateStats;
        GameManager.Instance.OnGameOver     -= ShowGameOver;
        GameManager.Instance.OnLivesChanged -= UpdateLives;
    }

    static void WireButton(string name, UnityEngine.Events.UnityAction action)
    {
        var go = GameObject.Find(name);
        if (go == null) return;
        var btn = go.GetComponent<Button>();
        if (btn != null) btn.onClick.AddListener(action);
    }

    void ShowHome()
    {
        if (HomePanel)    HomePanel.SetActive(true);
        if (ShopPanel)    ShopPanel.SetActive(false);
        if (HUD)          HUD.SetActive(false);
        if (GameOverPanel)GameOverPanel.SetActive(false);
        if (PausePanel)   PausePanel.SetActive(false);
        UpdateLives(GameManager.Instance.Lives);
    }

    void OnGameStarted()
    {
        if (HomePanel)    HomePanel.SetActive(false);
        if (ShopPanel)    ShopPanel.SetActive(false);
        if (HUD)          HUD.SetActive(true);
        if (GameOverPanel)GameOverPanel.SetActive(false);
        if (PausePanel)   PausePanel.SetActive(false);
    }

    void UpdateStats(int coins, float dist)
    {
        if (CoinsText)    CoinsText.text    = coins.ToString("N0");
        if (DistanceText) DistanceText.text = $"{dist:F1} km";
    }

    void UpdateLives(int lives)
    {
        if (HeartIcons == null) return;
        for (int i = 0; i < HeartIcons.Length; i++)
            HeartIcons[i].color = i < lives ? HeartActiveColor : HeartInactiveColor;
    }

    void ShowGameOver()
    {
        if (HUD)          HUD.SetActive(false);
        if (GameOverPanel)GameOverPanel.SetActive(true);
        if (GOCoinsText)    GOCoinsText.text    = GameManager.Instance.Coins.ToString("N0");
        if (GODistanceText) GODistanceText.text = $"{GameManager.Instance.Distance:F2} km";
    }

    public void OnStartGame() => GameManager.Instance?.StartGame();
    public void OnShop()      { if (ShopPanel) ShopPanel.SetActive(true); }
    public void OnCloseShop() { if (ShopPanel) ShopPanel.SetActive(false); }
    public void OnRevive()    { GameManager.Instance?.Revive(); if (GameOverPanel) GameOverPanel.SetActive(false); if (HUD) HUD.SetActive(true); }
    public void OnRestart()   => GameManager.Instance?.RestartGame();
    public void OnHome()      => GameManager.Instance?.GoToMainMenu();

    public void OnPause()
    {
        GameManager.Instance?.Pause();
        if (PausePanel) PausePanel.SetActive(true);
    }

    public void OnResume()
    {
        GameManager.Instance?.Resume();
        if (PausePanel) PausePanel.SetActive(false);
    }
}
