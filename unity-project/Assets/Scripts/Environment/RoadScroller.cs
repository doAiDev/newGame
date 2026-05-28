using UnityEngine;

public class RoadScroller : MonoBehaviour
{
    public float TileHeight = 20f;
    private Vector3 _startPos;

    void Start() => _startPos = transform.position;

    void Update()
    {
        if (GameManager.Instance == null) return;
        transform.Translate(Vector3.down * GameManager.Instance.Speed * Time.deltaTime);
        if (transform.position.y <= _startPos.y - TileHeight)
            transform.position = _startPos;
    }
}
