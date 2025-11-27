#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.AI;

public class NavMeshCutoutMinimapBaker : EditorWindow
{
    // ================== 基本設定 ==================
    int resolution = 512;

    Vector2 worldMin = new Vector2(-50, -50);
    Vector2 worldMax = new Vector2(50, 50);

    float sampleRadius = 0.3f;

    // ================== 顏色設定（由內到外） ==================
    public Color level0Color = Color.white;            // 可走核心
    public Color level1Color = Color.yellow;           // 可走內側邊界
    public Color level2Color = Color.red;              // 不可走內側邊界
    public Color level3Color = new Color(0.3f, 0.3f, 0.3f); // 不可走背景

    // ================== 厚度（只保留 Manual 比例） ==================
    [Range(0f, 1f)]
    public float innerThicknessFraction = 0.15f;   // 內側厚度（0~1）
    [Range(0f, 1f)]
    public float outerThicknessFraction = 0.15f;   // 外側厚度（0~1）

    [MenuItem("Tools/Minimap/NavMesh Cutout Minimap Baker")]
    public static void ShowWindow()
    {
        GetWindow<NavMeshCutoutMinimapBaker>("Cutout Minimap");
    }

    void OnGUI()
    {
        GUILayout.Label("NavMesh → Cutout Minimap", EditorStyles.boldLabel);

        // ------------ 基礎設定 ------------
        resolution = EditorGUILayout.IntField("Resolution", resolution);

        if (GUILayout.Button("從 NavMesh 取得範圍"))
            ApplyNavMeshBounds();

        worldMin = EditorGUILayout.Vector2Field("World Min (XZ)", worldMin);
        worldMax = EditorGUILayout.Vector2Field("World Max (XZ)", worldMax);

        sampleRadius = EditorGUILayout.FloatField("NavMesh Sample Radius", sampleRadius);

        // ------------ 顏色 ------------
        GUILayout.Space(8);
        GUILayout.Label("顏色（由內到外）", EditorStyles.boldLabel);

        level0Color = EditorGUILayout.ColorField("Level 0 (Walk Core)", level0Color);
        level1Color = EditorGUILayout.ColorField("Level 1 (Walk Edge)", level1Color);
        level2Color = EditorGUILayout.ColorField("Level 2 (Block Edge)", level2Color);
        level3Color = EditorGUILayout.ColorField("Level 3 (Block BG)", level3Color);

        // ------------ 厚度（純 Manual） ------------
        GUILayout.Space(8);
        GUILayout.Label("邊界厚度（手動）", EditorStyles.boldLabel);

        innerThicknessFraction = EditorGUILayout.Slider(
            "內側厚度比例（L1）", innerThicknessFraction, 0f, 1f);
        outerThicknessFraction = EditorGUILayout.Slider(
            "外側厚度比例（L2）", outerThicknessFraction, 0f, 1f);

        if (GUILayout.Button("套用預設值（0.15）"))
        {
            innerThicknessFraction = 0.15f;
            outerThicknessFraction = 0.15f;
            GUI.changed = true;
        }

        GUILayout.Space(10);
        if (GUILayout.Button("Bake Cutout Minimap"))
            Bake();
    }

    // ================== 從 NavMesh 計算 Bounds ==================

    void ApplyNavMeshBounds()
    {
        NavMeshTriangulation tri = NavMesh.CalculateTriangulation();
        if (tri.vertices.Length == 0)
        {
            Debug.LogWarning("NavMesh 未烘焙。");
            return;
        }

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

        Debug.Log("[CutoutMinimap] 使用 NavMesh 範圍");
    }

    // ================== 主流程 ==================

    void Bake()
    {
        bool[,] walkable = SampleNavMeshToGrid(out int w, out int h);

        float[,] innerDist;
        float maxInner;
        ComputeInnerDistanceField(walkable, out innerDist, out maxInner);

        float[,] outerDist;
        float maxOuter;
        ComputeOuterDistanceField(walkable, out outerDist, out maxOuter);

        if (maxInner <= 0f) maxInner = 1f;
        if (maxOuter <= 0f) maxOuter = 1f;

        float innerThreshold = innerThicknessFraction * maxInner;
        float outerThreshold = outerThicknessFraction * maxOuter;

        Texture2D cutout = GenerateCutoutTexture(
            walkable, innerDist, outerDist,
            w, h,
            innerThreshold, outerThreshold);

        SaveTexture(cutout, "minimap_cutout.png");

        Debug.Log(
            $"[CutoutMinimap] Bake 完成 | inner={innerThreshold:F2} | outer={outerThreshold:F2}");
    }

    bool[,] SampleNavMeshToGrid(out int w, out int h)
    {
        w = resolution;
        h = resolution;

        bool[,] grid = new bool[w, h];

        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                Vector3 wp = PixelToWorld(x, y);

                NavMeshHit hit;
                bool isWalkable = NavMesh.SamplePosition(wp, out hit, sampleRadius, NavMesh.AllAreas);
                grid[x, y] = isWalkable;
            }
        }

        return grid;
    }

    Vector3 PixelToWorld(int x, int y)
    {
        float fx = (float)x / (resolution - 1);
        float fy = (float)y / (resolution - 1);

        float wx = Mathf.Lerp(worldMin.x, worldMax.x, fx);
        float wz = Mathf.Lerp(worldMin.y, worldMax.y, fy);

        return new Vector3(wx, 0f, wz);
    }

    // ================== 內側距離場（可走 → 最近牆） ==================

    void ComputeInnerDistanceField(bool[,] walkable,
                                   out float[,] innerDist,
                                   out float maxInnerDist)
    {
        int w = walkable.GetLength(0);
        int h = walkable.GetLength(1);

        innerDist = new float[w, h];
        const float INF = float.PositiveInfinity;

        Queue<Vector2Int> q = new Queue<Vector2Int>();

        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                if (!walkable[x, y])
                {
                    innerDist[x, y] = 0f;
                    q.Enqueue(new Vector2Int(x, y));
                }
                else
                {
                    innerDist[x, y] = INF;
                }
            }
        }

        int[] dx = { 1, -1, 0, 0 };
        int[] dy = { 0, 0, 1, -1 };

        while (q.Count > 0)
        {
            var p = q.Dequeue();
            float cd = innerDist[p.x, p.y];

            for (int i = 0; i < 4; i++)
            {
                int nx = p.x + dx[i];
                int ny = p.y + dy[i];
                if (nx < 0 || nx >= w || ny < 0 || ny >= h)
                    continue;

                float nd = cd + 1f;

                if (nd < innerDist[nx, ny])
                {
                    innerDist[nx, ny] = nd;
                    q.Enqueue(new Vector2Int(nx, ny));
                }
            }
        }

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

    // ================== 外側距離場 ==================

    void ComputeOuterDistanceField(bool[,] walkable,
                                   out float[,] outerDist,
                                   out float maxOuterDist)
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

    // ================== 著色 ==================

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
                    float dIn = innerDist[x, y];

                    if (dIn <= innerThreshold)
                        c = level1Color;   // 走道邊線
                    else
                        c = level0Color;   // 走道核心
                }
                else
                {
                    float dOut = outerDist[x, y];

                    if (float.IsPositiveInfinity(dOut))
                    {
                        c = level3Color; // 非常遠，背景
                    }
                    else if (dOut <= outerThreshold)
                        c = level2Color; // 不可走邊線
                    else
                        c = level3Color; // 不可走背景
                }

                tex.SetPixel(x, y, c);
            }
        }

        tex.Apply();
        return tex;
    }

    // ================== 存檔 ==================

    void SaveTexture(Texture2D tex, string fileName)
    {
        string folder = "Assets/Minimaps/";
        if (!Directory.Exists(folder))
            Directory.CreateDirectory(folder);

        string path = Path.Combine(folder, fileName);
        File.WriteAllBytes(path, tex.EncodeToPNG());
        AssetDatabase.Refresh();

        Debug.Log("[CutoutMinimap] Saved: " + path);
    }
}
#endif
