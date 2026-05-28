// TMP 예제 파일 - 3D Physics 의존성 제거
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class CameraController : MonoBehaviour
{
    public float FieldOfView = 60.0f;
    public float EasingSpeed = 5.0f;

    private Camera m_Camera;

    void Awake()
    {
        m_Camera = GetComponent<Camera>();
        if (m_Camera != null)
            m_Camera.fieldOfView = FieldOfView;
    }

    void Update()
    {
        if (m_Camera == null) return;

        float scroll = Input.GetAxis("Mouse ScrollWheel");
        if (Mathf.Abs(scroll) > 0.01f)
        {
            FieldOfView = Mathf.Clamp(FieldOfView - scroll * 10f, 10f, 120f);
        }
        m_Camera.fieldOfView = Mathf.Lerp(m_Camera.fieldOfView, FieldOfView, Time.deltaTime * EasingSpeed);
    }
}
