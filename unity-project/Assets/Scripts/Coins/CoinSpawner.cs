using UnityEngine;

public class CoinSpawner : MonoBehaviour
{
    public GameObject CoinPrefab;
    public float SpawnInterval = 1.8f;
    public float SpawnY = 11f;
    public int Lanes = 3;
    public float LaneWidth = 2.0f;

    private float _timer;

    void Update()
    {
        if (GameManager.Instance == null) return;
        if (GameManager.Instance.State != GameState.Playing) return;
        if (CoinPrefab == null) return;
        _timer += Time.deltaTime;
        if (_timer >= SpawnInterval) { Spawn(); _timer = 0f; }
    }

    void Spawn()
    {
        int lane = Random.Range(0, Lanes);
        float half = Lanes * LaneWidth / 2f;
        float x = -half + LaneWidth * lane + LaneWidth / 2f;
        Instantiate(CoinPrefab, new Vector3(x, SpawnY, 0), Quaternion.identity);
    }
}
