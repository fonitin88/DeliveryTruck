#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.AI;

public class MiniMapBaker : EditorWindow
{
    int resolution = 256;
    //給工具一個初始範圍之後從 NavMesh 取得實際範圍
    Vector2 worldMin = new Vector2(-50, -50);
    Vector2 worldMax = new Vector2(50, 50);
    //來判斷可走 不可走區域
    float sampleRadius = 0.3f;
    //顏色
    public Color level0C = Color.white; //walkable
    public Color level1C = Color.yellow; //walkable border
    public Color level2C = Color.red; //nonwalkable border
    public Color level3C = Color.blue;//nonwalkable
    //border 寬度調整
    [Range(0f, 0.35f)]
    public float innerThickFraction = 0.15f;
    [Range(0f, 0.35f)]
    public float outerThickFraction = 0.15f;

    [MenuItem("Tools/MiniMap Baker")]
    public static void ShowWindow()
    {
        GetWindow<MiniMapBaker>("Minimap");
    }

    void OnGUI()
    {
        resolution = EditorGUILayout.IntField("Resolution", resolution);
        if (GUILayout.Button("Calculate range"))
        {
            ApplyNavMeshBounds();
        }
        worldMin = EditorGUILayout.Vector2Field("Range Min", worldMin);
        worldMax = EditorGUILayout.Vector2Field("Range Max", worldMax);
        sampleRadius = EditorGUILayout.FloatField("Sampling Radious", sampleRadius);
        GUILayout.Space(5);
        GUILayout.Label("Colors", EditorStyles.boldLabel);
        level0C = EditorGUILayout.ColorField("Walkable", level0C);
        level1C = EditorGUILayout.ColorField("Walkable Edge", level1C);
        level2C = EditorGUILayout.ColorField("Blocked Edge", level2C);
        level3C = EditorGUILayout.ColorField("Blocked", level3C);
        GUILayout.Space(5);
        GUILayout.Label("Edge Thickness", EditorStyles.boldLabel);
        innerThickFraction = EditorGUILayout.Slider("Walkable Edge Thickness", innerThickFraction, 0f, 0.33f);
        outerThickFraction = EditorGUILayout.Slider("Blocked Edge Thickness", outerThickFraction, 0f, 0.33f);
        if (GUILayout.Button("Default settings"))
        {
            innerThickFraction = 0.15f;
            outerThickFraction = 0.15f;
            GUI.changed = true;
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Bake MiniMap"))
        {
            Bake();
        }
    }
    //using navmesh to calculate the range (worldmin&max)
    void ApplyNavMeshBounds()
    {
        NavMeshTriangulation tri = NavMesh.CalculateTriangulation();
        if (tri.vertices.Length == 0)
        {
            Debug.LogWarning("Can't found the NavMesh");
            return;
        }
        //用第 1 個頂點來當初始化(裡面的值不一定是最小的)
        Vector3 min = tri.vertices[0];
        Vector3 max = tri.vertices[0];
        foreach (var v in tri.vertices)
        {
            if (v.x < min.x) min.x = v.x;
            if (v.z < min.z) min.z = v.z;
            if (v.x > max.x) max.x = v.x;
            if (v.z > max.z) max.z = v.z;
        }
        worldMin = new Vector2(min.x, min.z);
        worldMax = new Vector2(max.x, max.z);
    }
    void Bake()
    {
        //整張grid 中的walkable and nonwalkable的資訊，也代表知道了grid有幾格
        bool[,] walkable = SampleNavMeshToGrid(out int w, out int h);
        float[,] innerDist;
        float maxInner;
        //內側距離場（會拿到兩個值,最近的距離 和最長的距離）
        ComputeInnerDistanceField(walkable, out innerDist, out maxInner);

        float[,] outerDist;
        float maxOuter;
        ComputeOuterDistanceField(walkable, out outerDist, out maxOuter);

        if (maxInner <= 0f) maxInner = 1f;
        if (maxOuter <= 0f) maxOuter = 1f;

        float innerThreshold = innerThickFraction * maxInner;
        float outerThreshold = outerThickFraction * maxOuter;

        Texture2D cutout = GenerateCutoutTexture(
            walkable, innerDist, outerDist,
            w, h, innerThreshold, outerThreshold
        );
        SaveTexture(cutout, "minimap.png");

    }
    bool[,] SampleNavMeshToGrid(out int w, out int h)
    {
        w = resolution;
        h = resolution;
        bool[,] grid = new bool[w, h];
        //這整段是要算出navmesh 在resolution裡的格數是true or false
        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                //===這區主要是把3D世界對應成平面世界
                //先算出resolution的比例
                float fx = (float)x / (w - 1);
                float fy = (float)y / (h - 1);
                //這個是不是把navmesh縮小成 resolution像素大小阿?
                float wx = Mathf.Lerp(worldMin.x, worldMax.x, fx);
                float wz = Mathf.Lerp(worldMin.y, worldMax.y, fy);
                //就會獲得3Dnavmesh 轉成 在resolution大小中的資訊座標
                Vector3 worldPos = new Vector3(wx, 0f, wz);
                //===END

                NavMeshHit hit;
                //築格掃描判定
                bool isWalkable = NavMesh.SamplePosition(worldPos, out hit, sampleRadius, NavMesh.AllAreas);
                grid[x, y] = isWalkable;
            }
        }
        return grid;
    }
    //內側距離場（可走 → 最近牆）
    void ComputeInnerDistanceField(bool[,] walkable, out float[,] innerDist, out float maxInnerDist)
    {
        int w = walkable.GetLength(0);
        int h = walkable.GetLength(1);
        innerDist = new float[w, h]; //隨意的初始值而已
        const float INF = float.PositiveInfinity;//正無限大，不可能達成值
        Queue<Vector2Int> q = new Queue<Vector2Int>();//BFS 搜尋

        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                if (!walkable[x, y])//如果這邊是不可走區域
                {
                    innerDist[x, y] = 0f;//因為你站在障礙物上，距離自己 = 0
                    q.Enqueue(new Vector2Int(x, y));//把這個障礙物加入 Queue，作為 BFS 的『第一批任務』
                }
                else
                {
                    innerDist[x, y] = INF;
                }
            }
        }
        //四方向（上、下、左、右）移動的向量
        int[] dx = { 1, -1, 0, 0 };
        int[] dy = { 0, 0, 1, -1 };
        //BFS「擴散」的核心
        while (q.Count > 0)
        {
            var p = q.Dequeue();//從 Queue 拿出一個格子（FIFO → 最早加入的先出來）
            float cd = innerDist[p.x, p.y];//目前這格的距離是幾
            //四方向擴散（用 dx/dy）
            for (int i = 0; i < 4; i++)
            {
                //p的上下左右
                int nx = p.x + dx[i];
                int ny = p.y + dy[i];
                //邊界檢查（避免超出地圖）
                if (nx < 0 || nx >= w || ny < 0 || ny >= h)
                    continue;
                //計算鄰居的距離
                float nd = cd + 1f;
                //如果新距離（nd）比目前的小 → 更新
                if (nd < innerDist[nx, ny])
                {
                    innerDist[nx, ny] = nd;
                    q.Enqueue(new Vector2Int(nx, ny));
                }
            }
        }
        //最寬的距離
        maxInnerDist = 0f;
        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                if (!walkable[x, y]) continue;

                float d = innerDist[x, y];
                if (!float.IsPositiveInfinity(d) && d > maxInnerDist)
                    maxInnerDist = d;
            }
        }
    }
    //外側距離場
    void ComputeOuterDistanceField(bool[,] walkable, out float[,] outerDist, out float maxOuterDist)
    {
        int w = walkable.GetLength(0);
        int h = walkable.GetLength(1);

        outerDist = new float[w, h];
        const float INF = float.PositiveInfinity;
        Queue<Vector2Int> q = new Queue<Vector2Int>();

        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                if (walkable[x, y])
                {
                    outerDist[x, y] = 0f;
                    q.Enqueue(new Vector2Int(x, y));
                }
                else
                {
                    outerDist[x, y] = INF;
                }
            }
        }
        int[] dx = { 1, -1, 0, 0 };
        int[] dy = { 0, 0, 1, -1 };
        while (q.Count > 0)
        {
            var p = q.Dequeue();
            float cd = outerDist[p.x, p.y];
            for (int i = 0; i < 4; i++)
            {
                int nx = p.x + dx[i];
                int ny = p.y + dy[i];
                if (nx < 0 || nx >= w || ny < 0 || ny >= h)
                    continue;
                float nd = cd + 1f;
                if (nd < outerDist[nx, ny])
                {
                    outerDist[nx, ny] = nd;
                    q.Enqueue(new Vector2Int(nx, ny));
                }
            }
        }
        maxOuterDist = 0f;
        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                if (walkable[x, y]) continue;

                float d = outerDist[x, y];
                if (!float.IsPositiveInfinity(d) && d > maxOuterDist)
                    maxOuterDist = d;
            }
        }
    }
    Texture2D GenerateCutoutTexture(bool[,] walkable,
                                    float[,] innerDist,
                                    float[,] outerDist,
                                    int w,
                                    int h,
                                    float innerThreshold,
                                    float outerThreshold)

    {
        Texture2D tex = new Texture2D(w, h, TextureFormat.RGBA32, false);
        tex.filterMode = FilterMode.Point;
        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                bool isWalk = walkable[x, y];
                Color c;
                if (isWalk)
                {
                    //每一格都存放著障礙物到那格的距離資訊
                    float dIn = innerDist[x, y];
                    //再設定的範圍內就是走道邊緣
                    if (dIn <= innerThreshold)
                    {
                        c = level1C;
                    }
                    else
                    {
                        c = level0C;
                    }
                }
                else
                {
                    float dOut = outerDist[x, y];
                    if (float.IsPositiveInfinity(dOut))
                    {
                        c = level3C;
                    }
                    else if (dOut <= outerThreshold)
                    {
                        c = level2C;
                    }
                    else
                    {
                        c = level3C;
                    }
                }
                tex.SetPixel(x, y, c);
            }
        }
        tex.Apply();
        return tex;
    }

    void SaveTexture(Texture2D tex, string fileName)
    {
        string folder = "Assets/Minimaps/";
        if (!Directory.Exists(folder))
            Directory.CreateDirectory(folder);

        string path = Path.Combine(folder, fileName);
        File.WriteAllBytes(path, tex.EncodeToPNG());
        AssetDatabase.Refresh();

        // 自動修正 Import 設定
        FixTextureImportSettings(path);
    }

    void FixTextureImportSettings(string path)
    {
        TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
        if (importer == null) return;

        importer.textureType = TextureImporterType.Default;
        importer.mipmapEnabled = false;                   // 關掉 Mipmap
        importer.filterMode = FilterMode.Point;           // 不模糊
        importer.wrapMode = TextureWrapMode.Clamp;        // Clamp
        importer.textureCompression = TextureImporterCompression.Uncompressed;

        EditorUtility.SetDirty(importer);
        importer.SaveAndReimport();                       // 重新匯入
    }

}
#endif