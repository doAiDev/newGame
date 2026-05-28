using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UIManager : MonoBehaviour
{
    [Header("HUD")]
    public TextMeshProUGUI CoinsText;
    public TextMeshProUGUI DistanceText;
    public Image[] HeartIcons;
    public Color HeartActiveColor   = new Color(1f, 0.18f, 0.47f);
    public Color HeartInactiveColor = new Color(0.2f, 0.2f, 0.3f);

    [Header("Panels")]
    public GameObject GameOverPanel;
    public TextMeshProUGUI GOCoinsText;
    public TextMeshProUGUI GODistanceText;
    public GameObject PausePanel;

    void Start()
    {
        GameManager.Instance.OnStatsUpdate  += UpdateStats;
        GameManager.Instance.OnGameOver     += ShowGameOver;
        GameManager.Instance.OnLivesChanged += UpdateLives;

        GameOverPanel.SetActive(false);
        PausePanel.SetActive(false);
        UpdateLives(GameManager.Instance.Lives);
    }

    void OnDestroy()
    {
        if (GameManager.Instance == null) return;
        GameManager.Instance.OnStatsUpdate  -= UpdateStats;
        GameManager.Instance.OnGameOver     -= ShowGameOver;
        GameManager.Instance.OnLivesChanged -= UpdateLives;
    }

    void UpdateStats(int coins, float dist)
    {
        if (CoinsText)   CoinsText.text   = coins.ToString("N0");
        if (DistanceText) DistanceText.text = $"{dist:F1} km";
    }

    void UpdateLives(int lives)
    {
        for (int i = 0; i < HeartIcons.Length; i++)
            HeartIcons[i].color = i < lives ? HeartActiveColor : HeartInactiveColor;
    }

    void ShowGameOver()
    {
        GameOverPanel.SetActive(true);
        if (GOCoinsText)    GOCoinsText.text    = GameManager.Instance.Coins.ToString("N0");
        if (GODistanceText) GODistanceText.text = $"{GameManager.Instance.Distance:F2} km";
    }

    public void OnRevive()  { GameManager.Instance.Revive(); GameOverPanel.SetActive(false); }
    public void OnRestart() => GameManager.Instance.RestartGame();
    public void OnHome()    => GameManager.Instance.GoToMainMenu();

    public void OnPause()
    {
        GameManager.Instance.Pause();
        PausePanel.SetActive(true);
    }

    public void OnResume()
    {
        GameManager.Instance.Resume();
        PausePanel.SetActive(false);
    }
}
