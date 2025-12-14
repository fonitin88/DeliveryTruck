using UnityEngine;

public class HealthBarFollowUI : MonoBehaviour
{
    [SerializeField] Transform target;          // 指到 HP_Anchor
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

        Vector3 screenPos = cam.WorldToScreenPoint(target.position);

        // 在相機後面就隱藏，避免跑到奇怪位置
        if (screenPos.z <= 0f)
        {
            if (rt.gameObject.activeSelf) rt.gameObject.SetActive(false);
            return;
        }
        if (!rt.gameObject.activeSelf) rt.gameObject.SetActive(true);

        // Overlay Canvas：直接用螢幕座標
        rt.position = screenPos;
    }

    public void SetTarget(Transform t) => target = t;
}
