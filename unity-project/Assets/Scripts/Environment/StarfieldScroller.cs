using UnityEngine;

public class StarfieldScroller : MonoBehaviour
{
    public float ScrollSpeed = 1.5f;
    private Material _mat;
    private float _offset;

    void Start() => _mat = GetComponent<Renderer>().material;

    void Update()
    {
        if (GameManager.Instance == null) return;
        _offset += GameManager.Instance.Speed * ScrollSpeed * Time.deltaTime * 0.005f;
        _mat.mainTextureOffset = new Vector2(0, _offset);
    }
}
