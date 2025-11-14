using UnityEngine;

public class ColorView : MonoBehaviour
{
    [Header("換顏色的物件")]
    [SerializeField] Renderer targetRender;

    Material materailInstance;

    void Awake()
    {
        if (targetRender == null)
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
            materailInstance.color = color;
        }
    }
}
