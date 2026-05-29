using UnityEngine;
using UnityEngine.EventSystems;

public class Joystick : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
{
    public RectTransform Background;
    public RectTransform Handle;
    [Range(0f, 1f)] public float HandleRange = 0.85f;
    [Range(0f, 1f)] public float DeadZone = 0.08f;
    public bool HorizontalOnly = true;

    public float Horizontal { get; private set; }
    public float Vertical   { get; private set; }

    private Canvas _canvas;
    private Vector2 _input;

    void Start()
    {
        _canvas = GetComponentInParent<Canvas>();
    }

    public void OnPointerDown(PointerEventData e) => OnDrag(e);

    public void OnDrag(PointerEventData e)
    {
        Vector2 pos    = RectTransformUtility.WorldToScreenPoint(_canvas.worldCamera, Background.position);
        Vector2 radius = Background.rect.size / 2f * _canvas.scaleFactor;
        if (radius.sqrMagnitude < 0.001f) return; // guard against zero-size

        _input = (e.position - pos) / radius;

        if (HorizontalOnly) _input.y = 0f;
        if (_input.magnitude > DeadZone)
        {
            if (_input.magnitude > 1f) _input = _input.normalized;
        }
        else
        {
            _input = Vector2.zero;
        }

        Handle.anchoredPosition = _input * Background.rect.size / 2f * HandleRange;
        Horizontal = _input.x;
        Vertical   = _input.y;
    }

    public void OnPointerUp(PointerEventData e)
    {
        _input = Vector2.zero;
        Handle.anchoredPosition = Vector2.zero;
        Horizontal = 0f;
        Vertical   = 0f;
    }
}
