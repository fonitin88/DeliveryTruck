using UnityEngine;

public class PrefabBrushTool : MonoBehaviour
{
    public GameObject prefab;
    public float brushRadius = 2.0f;
    public int density = 5;
    public float spacing = 0.5f;
    public bool alignToSurface = true;//地形貼合
    public bool randomRotation = true;
    public Vector2 randomScaleRange = new Vector2(1f, 1f);

}
