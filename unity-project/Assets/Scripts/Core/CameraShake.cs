using System.Collections;
using UnityEngine;

public class CameraShake : MonoBehaviour
{
    public static CameraShake Instance { get; private set; }

    private Vector3 _originalPos;

    void Awake()
    {
        Instance = this;
        _originalPos = transform.localPosition;
    }

    public void Shake(float duration = 0.25f, float magnitude = 0.18f)
    {
        StartCoroutine(ShakeRoutine(duration, magnitude));
    }

    IEnumerator ShakeRoutine(float duration, float magnitude)
    {
        float elapsed = 0f;
        while (elapsed < duration)
        {
            transform.localPosition = _originalPos + (Vector3)Random.insideUnitCircle * magnitude;
            elapsed += Time.deltaTime;
            yield return null;
        }
        transform.localPosition = _originalPos;
    }
}
