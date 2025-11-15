using UnityEngine;
[RequireComponent(typeof(Renderer))]   // 自動強制加 Renderer
public class ColorView : MonoBehaviour
{
    [Header("換顏色的物件")]
    [SerializeField] Renderer targetRender;

    Material materailInstance;
    void Reset()
    {
        // Reset 在 Inspector 加上 Script 時自動執行
        targetRender = GetComponent<Renderer>();
    }

    void Awake()
    {
        if (targetRender == null)
        {
            // 自動抓自己身上的 Renderer（如果有）
            targetRender = GetComponentInChildren<Renderer>();
        }
        if (targetRender != null)
        {
            materailInstance = targetRender.material;
        }
        else
        {
            Debug.LogWarning("no render");
        }
    }

    public void UpdateColor(Color color)
    {
        if (materailInstance != null)
        {
            materailInstance.SetColor("_MainColor", color);
        }
    }


}
