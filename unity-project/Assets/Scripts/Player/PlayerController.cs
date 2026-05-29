using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
public class PlayerController : MonoBehaviour
{
    [Header("Lanes")]
    public int TotalLanes = 3;
    public float LaneWidth = 2.0f;

    [Header("Movement")]
    public float MoveSmoothness = 10f;

    [Header("Effects")]
    public ParticleSystem ThrusterParticles;
    public TrailRenderer NeonTrail;

    private float _targetX;
    private float _leftBound;
    private float _rightBound;
    private bool _isDead = false;
    private Rigidbody2D _rb;
    private Joystick _joystick;

    void Start()
    {
        _rb = GetComponent<Rigidbody2D>();
        _rb.gravityScale = 0f;
        _rb.constraints = RigidbodyConstraints2D.FreezeRotation;

        _joystick = FindObjectOfType<Joystick>();

        float half = (TotalLanes * LaneWidth) / 2f;
        _leftBound  = -half + LaneWidth * 0.5f;
        _rightBound =  half - LaneWidth * 0.5f;
        _targetX = transform.position.x;
    }

    void Update()
    {
        if (_isDead || GameManager.Instance == null) return;
        if (GameManager.Instance.State != GameState.Playing) return;

        float input = _joystick != null ? _joystick.Horizontal : 0f;
        if (Mathf.Abs(input) > 0.1f)
        {
            _targetX += input * GameManager.Instance.Speed * 0.28f * Time.deltaTime;
            _targetX = Mathf.Clamp(_targetX, _leftBound, _rightBound);
        }
    }

    void FixedUpdate()
    {
        if (_isDead) return;
        float newX = Mathf.Lerp(_rb.position.x, _targetX, MoveSmoothness * Time.fixedDeltaTime);
        _rb.MovePosition(new Vector2(newX, _rb.position.y));
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (GameManager.Instance == null || GameManager.Instance.State != GameState.Playing) return;
        if (other.CompareTag("Traffic"))
        {
            Destroy(other.gameObject);
            GameManager.Instance.TakeDamage();
            if (GameManager.Instance.Lives <= 0) Die();
        }
        else if (other.CompareTag("Coin"))
        {
            GameManager.Instance.AddCoin(10);
            Destroy(other.gameObject);
        }
    }

    void Die()
    {
        _isDead = true;
        if (ThrusterParticles) ThrusterParticles.Stop();
        if (NeonTrail) NeonTrail.emitting = false;
    }
}
