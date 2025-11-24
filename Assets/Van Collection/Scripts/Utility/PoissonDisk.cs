using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public static class PoissonDisk
{
    public static List<Vector2> GeneratePoints(float radius, Vector2 regionSize, int rejectionSamples = 30)
    {
        float cellSize = radius / Mathf.Sqrt(2);//格子的邊長
        int gridWidth = Mathf.CeilToInt(regionSize.x / cellSize); //算出幾等分嗎?
        int gridHight = Mathf.CeilToInt(regionSize.y / cellSize);

        int[,] grid = new int[gridWidth, gridHight];
        List<Vector2> points = new List<Vector2>();
        List<Vector2> spawnPoints = new List<Vector2>();

        spawnPoints.Add(regionSize / 2);//第一個隨便放中心

        //如果合格 → 加到結果, 如果不行 → 試別的, 都不行 → 不再從這點生新點
        while (spawnPoints.Count > 0)
        {
            //隨機挑一個可spawn的點,點叫 spawnCenter
            int spawnIndex = Random.Range(0, spawnPoints.Count);
            Vector2 spawnCenter = spawnPoints[spawnIndex];
            bool accepted = false;
            //試著生成新點
            for (int i = 0; i < rejectionSamples; i++)
            {
                //隨機產生一個候選點 candidate
                float angle = Random.value * Mathf.PI * 2;//隨機角度
                float dist = Random.Range(radius, 2 * radius); //隨機距離
                //用這些值算出新點座標
                Vector2 candidate = spawnCenter + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * dist;

                if (IsValid(candidate, regionSize, radius, points, grid, cellSize))
                {
                    points.Add(candidate);
                    spawnPoints.Add(candidate);

                    //把 candidate 記錄到 grid 裡
                    int cx = (int)(candidate.x / cellSize);
                    int cy = (int)(candidate.y / cellSize);
                    grid[cx, cy] = points.Count;

                    accepted = true;
                    break;
                }
            }
            if (!accepted)
            {
                spawnPoints.RemoveAt(spawnIndex);
            }
        }


        return points;
    }
    //Poisson Disk 驗證候選點（candidate）是否合法
    private static bool IsValid(Vector2 candidate, Vector2 regionSize,
    float radius, List<Vector2> points, int[,] grid, float cellSize)
    {
        //檢查 candidate 是否超出區域
        if (candidate.x < 0 || candidate.x >= regionSize.x || candidate.y < 0 || candidate.y >= regionSize.y)
        {
            return false;
        }
        //找出 candidate 落在哪個 grid cell
        int cellX = (int)(candidate.x / cellSize);
        int cellY = (int)(candidate.y / cellSize);

        //只需要檢查距離最多 2 個格子的鄰居
        int searchStartX = Mathf.Max(0, cellX - 2);
        int searchEndX = Mathf.Min(grid.GetLength(0) - 1, cellX + 2);
        int searchStartY = Mathf.Max(0, cellY - 2);
        int searchEndY = Mathf.Min(grid.GetLength(1) - 1, cellY + 2);

        for (int x = searchStartX; x <= searchEndX; x++)
        {
            for (int y = searchStartY; y <= searchEndY; y++)
            {
                int pointIndex = grid[x, y] - 1;
                if (pointIndex != -1)
                {
                    //兩點的距離平方
                    float sqrDist = (candidate - points[pointIndex]).sqrMagnitude;
                    if (sqrDist < radius * radius)
                        return false;
                }
            }
        }

        return true;

    }

}
