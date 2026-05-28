using UnityEngine;

/// <summary>
/// Sprite Renderer의 에미션 색상을 진동시켜 네온 글로우 효과를 냅니다.
/// Material에 HDR 에미션이 활성화됐 있어야 합니다.
/// </summary>
[RequireComponent(typeof(SpriteRenderer))]
public class NeonGlow : MonoBehaviour
{
    public Color GlowColor = new Color(0f, 1f, 0.78f, 1f);
    [Range(0.5f, 3f)] public float MinIntensity = 1f;
    [Range(1f, 5f)]   public float MaxIntensity = 2.5f;
    public float PulseSpeed = 2f;

    private SpriteRenderer _sr;
    private MaterialPropertyBlock _mpb;

    void Awake()
    {
        _sr  = GetComponent<SpriteRenderer>();
        _mpb = new MaterialPropertyBlock();
    }

    void Update()
    {
        float t = (Mathf.Sin(Time.time * PulseSpeed) + 1f) / 2f;
        float intensity = Mathf.Lerp(MinIntensity, MaxIntensity, t);
        _sr.GetPropertyBlock(_mpb);
        _mpb.SetColor("_EmissionColor", GlowColor * intensity);
        _sr.SetPropertyBlock(_mpb);
    }
}
