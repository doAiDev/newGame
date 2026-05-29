using UnityEngine;

public class Joystick : MonoBehaviour
{
    public RectTransform Background;
    public RectTransform Handle;
    [Range(0f, 1f)] public float HandleRange = 0.85f;
    [Range(0f, 1f)] public float DeadZone = 0.08f;
    public bool HorizontalOnly = true;

    public float Horizontal { get; private set; }
    public float Vertical   { get; private set; }

    private Canvas _canvas;

    void Start()
    {
        _canvas = GetComponentInParent<Canvas>();
    }

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Vector2 touchPos = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
            // only respond to touches in the lower 60% of screen (avoid UI buttons at top)
            if (touchPos.y < Screen.height * 0.6f)
                ProcessInput(touchPos);
            else
                Release();
        }
        else
        {
            Release();
        }
    }

    void Release()
    {
        Horizontal = 0f;
        Vertical   = 0f;
        if (Handle) Handle.anchoredPosition = Vector2.zero;
    }

    void ProcessInput(Vector2 touchPos)
    {
        if (Background == null || _canvas == null) return;

        Vector2 center = RectTransformUtility.WorldToScreenPoint(_canvas.worldCamera, Background.position);
        float radius = Background.rect.width / 2f * _canvas.scaleFactor;
        if (radius < 1f) return;

        Vector2 delta = touchPos - center;
        if (HorizontalOnly) delta.y = 0f;

        Vector2 norm = delta / radius;
        if (norm.magnitude > 1f) norm = norm.normalized;

        if (norm.magnitude > DeadZone)
        {
            Horizontal = norm.x;
            Vertical   = norm.y;
        }
        else
        {
            Horizontal = 0f;
            Vertical   = 0f;
        }

        if (Handle)
            Handle.anchoredPosition = norm * Background.rect.size / 2f * HandleRange;
    }
}
