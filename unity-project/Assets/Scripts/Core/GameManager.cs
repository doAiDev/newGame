using UnityEngine;
using UnityEngine.SceneManagement;

public enum GameState { Home, Playing, Paused, GameOver }

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public GameState State  { get; private set; } = GameState.Home;
    public int   Lives    { get; private set; } = 3;
    public int   Coins    { get; private set; } = 0;
    public float Distance { get; private set; } = 0f;
    public float Speed    { get; private set; } = 3f; // slow road scroll in HOME

    private const float StartSpeed   = 6f;
    private const float MaxSpeed     = 22f;
    private const float SpeedIncrement = 0.25f;

    public event System.Action OnGameStarted;
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
        if (State != GameState.Playing) return;
        Speed     = Mathf.Min(MaxSpeed, Speed + SpeedIncrement * Time.deltaTime);
        Distance += Speed * Time.deltaTime / 10f;
        OnStatsUpdate?.Invoke(Coins, Distance);
    }

    public void StartGame()
    {
        Lives    = 3;
        Coins    = 0;
        Distance = 0f;
        Speed    = StartSpeed;
        State    = GameState.Playing;
        OnLivesChanged?.Invoke(Lives);
        OnStatsUpdate?.Invoke(Coins, Distance);
        OnGameStarted?.Invoke();
    }

    public void AddCoin(int value)
    {
        Coins += value;
        OnStatsUpdate?.Invoke(Coins, Distance);
    }

    public void TakeDamage()
    {
        if (State != GameState.Playing) return;
        Lives--;
        OnLivesChanged?.Invoke(Lives);
        CameraShake.Instance?.Shake();
        if (Lives <= 0) { State = GameState.GameOver; OnGameOver?.Invoke(); }
    }

    public void Revive()
    {
        Lives  = 1;
        Speed  = StartSpeed;
        State  = GameState.Playing;
        OnLivesChanged?.Invoke(Lives);
    }

    public void Pause()
    {
        if (State != GameState.Playing) return;
        State = GameState.Paused;
        Time.timeScale = 0f;
    }

    public void Resume()
    {
        if (State != GameState.Paused) return;
        State = GameState.Playing;
        Time.timeScale = 1f;
    }

    public void RestartGame()  { Time.timeScale = 1f; SceneManager.LoadScene(SceneManager.GetActiveScene().name); }
    public void GoToMainMenu() { Time.timeScale = 1f; SceneManager.LoadScene(SceneManager.GetActiveScene().name); }
}
