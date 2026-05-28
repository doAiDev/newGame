using UnityEngine;

public class TrafficCar : MonoBehaviour
{
    public float DestroyBelowY = -12f;

    void Update()
    {
        if (GameManager.Instance == null) return;
        transform.Translate(Vector3.down * GameManager.Instance.Speed * Time.deltaTime);
        if (transform.position.y < DestroyBelowY) Destroy(gameObject);
    }
}
