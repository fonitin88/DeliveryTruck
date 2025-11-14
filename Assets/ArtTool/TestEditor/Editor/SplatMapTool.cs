using UnityEditor;
using UnityEngine;

public class SplatMapTool : EditorWindow
{
    Terrain targetTerrain;
    Texture2D splatMap;
    int rLayer = 0, gLayer = 1, bLayer = 2, aLayer = 3;

    [MenuItem("Tools/SplatMap Tool")]
    public static void ShowWindow()
    {
        GetWindow<SplatMapTool>("SplatMap Tool");
    }
    void OnGUI()
    {
        EditorGUILayout.LabelField("Terrain", EditorStyles.boldLabel);
        //ObjectField：選 Terrain
        targetTerrain = (Terrain)EditorGUILayout.ObjectField("terrain", targetTerrain, typeof(Terrain), true);

        // ObjectField：選 SplatMap Texture
        splatMap = (Texture2D)EditorGUILayout.ObjectField("splatMap", splatMap, typeof(Texture2D), true);
        // IntField：選各通道對應 Layer
        rLayer = EditorGUILayout.IntField("R", rLayer);
        gLayer = EditorGUILayout.IntField("G", gLayer);
        bLayer = EditorGUILayout.IntField("B", bLayer);
        aLayer = EditorGUILayout.IntField("A", aLayer);

        // Button：「Apply to Terrain」
        if (GUILayout.Button("Apply to Terrain"))
        {
            ApplySplatMap();
        }
    }
    void ApplySplatMap()
    {
        if (targetTerrain == null || splatMap == null)
        {
            Debug.LogWarning("請先選擇 Terrain 與 SplatMap 貼圖！");
            return;
        }

        // terrainData
        TerrainData data = targetTerrain.terrainData;
        int h = data.alphamapHeight;
        int w = data.alphamapWidth;

        //new 容器
        float[,,] alphamap = new float[h, w, data.alphamapLayers];

        // for 來 讀出每個像素顏色 
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++)
            {
                // 用.GetPixelBilinear(u,v)  從貼圖取出「顏色」變成0-1的值 
                Color c = splatMap.GetPixelBilinear((float)x / h, (float)y / w);
                // 寫入 alphamap 
                alphamap[y, x, rLayer] = c.r;
                alphamap[y, x, gLayer] = c.g;
                alphamap[y, x, bLayer] = c.b;
                alphamap[y, x, aLayer] = c.a;
            }


        //Undo
        Undo.RecordObject(data, "Apply to Terrain");

        // 套用到地形 SetAlphamaps內部會自己逐格寫入整個陣列資料
        data.SetAlphamaps(0, 0, alphamap);

    }

}