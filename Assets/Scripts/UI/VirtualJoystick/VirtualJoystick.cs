using UnityEngine;
using UnityEngine.EventSystems;

public class VirtualJoystick : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
{
    [SerializeField] RectTransform handle;
    [SerializeField] float radius = 80f; // 搖桿可推的最大距離（像素）

    Vector2 input; // -1~1
    RectTransform bg;

    public Vector2 InputVector => input;

    void Awake()
    {
        bg = (RectTransform)transform;
        if (handle != null) handle.anchoredPosition = Vector2.zero;
    }

    public void OnPointerDown(PointerEventData eventData) => OnDrag(eventData);

    public void OnDrag(PointerEventData eventData)
    {
        if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(
                bg, eventData.position, eventData.pressEventCamera, out var local))
            return;

        // local 直接就是以 BG 中心為 (0,0)
        Vector2 clamped = Vector2.ClampMagnitude(local, radius);
        if (handle != null) handle.anchoredPosition = clamped;

        input = clamped / radius; // 轉成 -1~1

    }

    public void OnPointerUp(PointerEventData eventData)
    {
        input = Vector2.zero;
        if (handle != null) handle.anchoredPosition = Vector2.zero;
    }
}
