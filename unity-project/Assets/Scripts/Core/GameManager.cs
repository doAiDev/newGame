using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public int Lives { get; private set; } = 3;
    public int Coins { get; private set; } = 0;
    public float Distance { get; private set; } = 0f;
    public float Speed { get; private set; } = 6f;

    private const float MaxSpeed = 22f;
    private const float SpeedIncrement = 0.25f;

    private bool _isGameOver = false;
    private bool _isPaused = false;

    public event System.Action OnGameOver;
    public event System.Action<int, float> OnStatsUpdate;
    public event System.Action<int> OnLivesChanged;

    void Awake()
    {
        if (Instance != null && Instance != this) { Destroy(gameObject); return; }
        Instance = this;
    }

    void Update()
    {
        if (_isGameOver || _isPaused) return;
        Speed = Mathf.Min(MaxSpeed, Speed + SpeedIncrement * Time.deltaTime);
        Distance += Speed * Time.deltaTime / 10f;
        OnStatsUpdate?.Invoke(Coins, Distance);
    }

    public void AddCoin(int value)
    {
        Coins += value;
        OnStatsUpdate?.Invoke(Coins, Distance);
    }

    public void TakeDamage()
    {
        if (_isGameOver) return;
        Lives--;
        OnLivesChanged?.Invoke(Lives);
        CameraShake.Instance?.Shake();
        if (Lives <= 0) { _isGameOver = true; OnGameOver?.Invoke(); }
    }

    public void Revive()
    {
        Lives = 1;
        Speed = 6f;
        _isGameOver = false;
    }

    public void Pause() { _isPaused = true; Time.timeScale = 0f; }
    public void Resume() { _isPaused = false; Time.timeScale = 1f; }
    public void RestartGame() { Time.timeScale = 1f; SceneManager.LoadScene(SceneManager.GetActiveScene().name); }
    public void GoToMainMenu() { Time.timeScale = 1f; SceneManager.LoadScene("MainMenu"); }
}
