using System;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "EnvTools/Spawn Settings", fileName = "SpawnSettings")]
public class SpawnSettings : ScriptableObject
{

    [Header("Grid 設定")]
    public int gridXCount = 5;
    public int gridYCount = 5;

    [Header("生成 Prefab")]
    public GameObject prefab;

    [Header("生成設定")]
    public int totalSpawnCount = 100;

    [Header("碰撞檢查")]
    public LayerMask collisionMask = ~0;// 用來排除 Terrain 等層

    [Header("群組名稱")]
    public Transform parentRoot;

    [Header("Grid 區域密度")]
    public List<SpawnRegion> regions = new List<SpawnRegion>();

    public void RebuildRegions()
    {
        regions.Clear();
        for (int y = 0; y < gridYCount; y++)
        {
            for (int x = 0; x < gridXCount; x++)
            {
                regions.Add(new SpawnRegion
                {
                    gridIndex = new Vector2Int(x, y),
                    density = 0.5f
                });
            }
        }
    }

    public SpawnRegion GetRegion(int x, int y)
    {
        int index = y * gridXCount + x;
        if (index < 0 || index >= regions.Count) return null;
        return regions[index];
    }
}
