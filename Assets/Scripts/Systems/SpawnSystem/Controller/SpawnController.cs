using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class SpawnController
{
    public static void Generate(SpawnSettings settings, Terrain terrain)
    {
        if (settings == null)
        {
            Debug.LogError("[SpawnController] Settings 或 Terrain 未設定");
            return;
        }
        if (terrain == null)
        {
            Debug.LogError("[SpawnController] Terrain 未指定");
            return;
        }
        if (settings.prefab == null)
        {
            Debug.LogError("[SpawnController] prefab 未指定");
            return;
        }

        TerrainData data = terrain.terrainData;
        Vector3 tPos = terrain.transform.position;
        Vector3 tSize = data.size;

        float cellW = tSize.x / settings.gridXCount;
        float cellH = tSize.z / settings.gridYCount;

        // 建立群組 好方便管理
        Transform parent = settings.parentRoot;
        if (parent == null)
        {
            GameObject p = new GameObject("Generated_Objects");
            settings.parentRoot = p.transform; // 設定檔 SpawnSettings 也記住這個新 parent
            parent = p.transform;              // 存到本地變數 parent（在這次 Generate 裡用）
        }

        // 計算 density 總和
        float totalDensity = 0;
        foreach (var r in settings.regions)
        {
            totalDensity += r.density;
        }
        if (totalDensity <= 0)
        {
            Debug.LogWarning("[SpawnController] 所有區域的密度都是 0");
            return;
        }

        // 估 Prefab 大小，讓最小距離不要小於物件尺寸
        float prefabRadius = 0.0f;
        Renderer rend = settings.prefab.GetComponentInChildren<Renderer>();
        if (rend != null)
        {
            Vector3 ext = rend.bounds.extents;
            prefabRadius = Mathf.Max(ext.x, ext.z); // 取 XZ 最大半徑
        }
        if (prefabRadius <= 0f)
        {
            prefabRadius = 0.5f; // 預設一個合理值
        }

        int totalPlaced = 0;

        // 每個區域跑 Poisson Disk
        for (int y = 0; y < settings.gridYCount; y++)
        {
            for (int x = 0; x < settings.gridXCount; x++)
            {
                var region = settings.GetRegion(x, y);
                if (region == null || region.density <= 0f)
                    continue;

                int regionCount = Mathf.RoundToInt(settings.totalSpawnCount * (region.density / totalDensity));

                float minX = tPos.x + x * cellW;
                float maxX = minX + cellW;
                float minZ = tPos.z + y * cellH;
                float maxZ = minZ + cellH;

                Vector2 regionSize = new Vector2(cellW, cellH);

                float areaPerPoint = (cellW * cellH) / Mathf.Max(1, regionCount);
                float autoRadius = Mathf.Sqrt(areaPerPoint) * 0.5f;

                autoRadius = Mathf.Max(autoRadius, prefabRadius);

                List<Vector2> poissonPoints = PoissonDisk.GeneratePoints(autoRadius, regionSize);
                if (poissonPoints.Count == 0)
                    continue;

                int usedCount = Mathf.Min(regionCount, poissonPoints.Count);

                for (int i = 0; i < usedCount; i++)
                {
                    Vector2 local = poissonPoints[i];

                    float wx = minX + local.x;
                    float wz = minZ + local.y;
                    float wy = terrain.SampleHeight(new Vector3(wx, 0, wz)) + tPos.y;

                    Vector3 pos = new Vector3(wx, wy, wz);

                    if (Physics.CheckSphere(pos, 0.01f, settings.collisionMask))
                        continue;

                    GameObject go;

#if UNITY_EDITOR
                    // 在 Editor：生成藍色、有 prefab 連結
                    go = (GameObject)PrefabUtility.InstantiatePrefab(settings.prefab, parent);
#else
                    // 在 Build / 遊戲中：用一般 Instantiate
                    go = Object.Instantiate(settings.prefab, parent);
#endif

                    go.transform.SetPositionAndRotation(pos, Quaternion.identity);

                    totalPlaced++;
                }
            }
        }

        Debug.Log($"[SpawnController] Poisson 分散生成完成，共生成 {totalPlaced} 個物件。");
    }

    public static void ClearGenerated(SpawnSettings settings)
    {
        if (settings == null || settings.parentRoot == null) return;

        var children = new List<Transform>();
        foreach (Transform c in settings.parentRoot) children.Add(c);

        foreach (var c in children)
        {
#if UNITY_EDITOR
            Object.DestroyImmediate(c.gameObject);
#else
            Object.Destroy(c.gameObject);
#endif
        }

        Debug.Log("[SpawnController] 已清除所有生成物件");
    }
}
