using UnityEngine;

public class TrafficSpawner : MonoBehaviour
{
    public GameObject[] CarPrefabs;
    public float BaseInterval = 1.4f;
    public float SpawnY = 11f;
    public int Lanes = 3;
    public float LaneWidth = 2.0f;

    private float _timer;

    float Interval
    {
        get
        {
            if (GameManager.Instance == null) return BaseInterval;
            return BaseInterval / Mathf.Max(1f, GameManager.Instance.Speed / 6f);
        }
    }

    void Update()
    {
        if (GameManager.Instance == null) return;
        if (GameManager.Instance.State != GameState.Playing) return;
        if (CarPrefabs == null || CarPrefabs.Length == 0) return;
        _timer += Time.deltaTime;
        if (_timer >= Interval) { Spawn(); _timer = 0f; }
    }

    void Spawn()
    {
        int lane = Random.Range(0, Lanes);
        float half = Lanes * LaneWidth / 2f;
        float x = -half + LaneWidth * lane + LaneWidth / 2f;
        var prefab = CarPrefabs[Random.Range(0, CarPrefabs.Length)];
        Instantiate(prefab, new Vector3(x, SpawnY, 0), Quaternion.identity);
    }
}
