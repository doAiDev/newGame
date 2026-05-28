using UnityEngine;

public class CoinController : MonoBehaviour
{
    public float RotateSpeed = 180f;
    public float DestroyBelowY = -12f;
    public ParticleSystem CollectFX;

    void Update()
    {
        if (GameManager.Instance == null) return;
        transform.Translate(Vector3.down * GameManager.Instance.Speed * Time.deltaTime);
        transform.Rotate(0f, 0f, RotateSpeed * Time.deltaTime);  // Z축 회전 = 2D 스핀
        if (transform.position.y < DestroyBelowY) Destroy(gameObject);
    }
}
