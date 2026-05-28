using UnityEngine;

/// <summary>
/// 속도에 따라 파티클 시스템의 발사 속도를 조절합니다.
/// </summary>
[RequireComponent(typeof(ParticleSystem))]
public class SpeedLines : MonoBehaviour
{
    public float MaxEmissionRate = 80f;

    private ParticleSystem _ps;

    void Start() => _ps = GetComponent<ParticleSystem>();

    void Update()
    {
        if (GameManager.Instance == null) return;
        float ratio = GameManager.Instance.Speed / 22f;
        var emission = _ps.emission;
        emission.rateOverTime = ratio * MaxEmissionRate;
    }
}
