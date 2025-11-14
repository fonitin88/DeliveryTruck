using UnityEngine;

public class CarPaintController : MonoBehaviour
{
    public Renderer carRenderer;
    public Color carColor = Color.red;

    [Tooltip("Shader Graph 中顏色屬性的名字，記得加底線 _ 開頭")]
    public string colorPropertyName = "_MainColor";

    public void ApplyColor()
    {
        if (carRenderer != null && carRenderer.material.HasProperty(colorPropertyName))
        {
            carRenderer.material.SetColor(colorPropertyName, carColor);
        }
        else
        {
            Debug.LogWarning("材質上找不到顏色屬性：" + colorPropertyName);
        }
    }
}

