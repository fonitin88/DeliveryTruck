using UnityEngine;

public class WorldToUIFollow : MonoBehaviour
{
    [SerializeField] Transform target;      // player 或 head anchor
    [SerializeField] Vector3 worldOffset = new Vector3(0, 2f, 0);
    RectTransform rt;
    Camera cam;

    void Awake()
    {
        rt = (RectTransform)transform;
        cam = Camera.main;
    }

    void LateUpdate()
    {
        if (!target) return;
        if (!cam) cam = Camera.main;
        if (!cam) return;

        Vector3 worldPos = target.position + worldOffset;
        Vector3 screenPos = cam.WorldToScreenPoint(worldPos);

        // 在相機後面就隱藏（避免翻到螢幕亂跳）
        if (screenPos.z <= 0f)
        {
            rt.gameObject.SetActive(false);
            return;
        }
        else
        {
            if (!rt.gameObject.activeSelf) rt.gameObject.SetActive(true);
        }

        rt.position = screenPos; // Canvas 是 Screen Space，直接用螢幕座標
    }

    public void SetTarget(Transform t) => target = t;
}
