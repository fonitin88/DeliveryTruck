using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;


public class RotateOnDrag : MonoBehaviour
{
    [SerializeField] float rotateSpeed = 0.3f;
    [SerializeField] float minY = -60f;
    [SerializeField] float maxY = 65f;

    bool dragging;
    Vector2 lastPos;

    void Update()
    {
        // --- Touch (Mobile/WebGL mobile browser) ---
        if (Touchscreen.current != null)
        {
            var touch = Touchscreen.current.primaryTouch;

            if (touch.press.wasPressedThisFrame)
            {
                dragging = true;
                lastPos = touch.position.ReadValue();
            }

            if (dragging && touch.press.isPressed)
            {
                Vector2 pos = touch.position.ReadValue();
                ApplyRotate(pos);
            }

            if (touch.press.wasReleasedThisFrame)
                dragging = false;

            return; // 有觸控裝置就不要再走滑鼠
        }

        // --- Mouse (Desktop Web) ---
        if (Mouse.current == null) return;

        if (Mouse.current.leftButton.wasPressedThisFrame)
        {
            dragging = true;
            lastPos = Mouse.current.position.ReadValue();
        }

        if (dragging && Mouse.current.leftButton.isPressed)
        {
            Vector2 pos = Mouse.current.position.ReadValue();
            ApplyRotate(pos);
        }

        if (Mouse.current.leftButton.wasReleasedThisFrame)
            dragging = false;
    }
    //旋轉
    void ApplyRotate(Vector2 pos)
    {
        Vector2 delta = pos - lastPos;
        lastPos = pos;

        float rotateAmount = -delta.x * rotateSpeed;

        float currentY = transform.eulerAngles.y;
        if (currentY > 180f) currentY -= 360f;

        float newY = Mathf.Clamp(currentY + rotateAmount, minY, maxY);
        transform.rotation = Quaternion.Euler(0f, newY, 0f);
    }
}
