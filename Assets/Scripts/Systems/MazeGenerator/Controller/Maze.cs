#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Maze
{
    private struct MazeCell
    {
        //格子的內容 演算法開始前不需要給預設值 所以預設是false
        public bool visited;
        public bool northWall;
        public bool southWall;
        public bool eastWall;
        public bool westWall;
    }

    // 從 Prefab 抓實際尺寸，用renderer.bounds
    public static bool TryGetPrefabMetrics(GameObject wallPrefab, out float tileSize)
    {
        tileSize = 1f;//一定要有一個值
        if (wallPrefab == null) return false;//防呆
        var renderer = wallPrefab.GetComponentInChildren<Renderer>();
        if (renderer == null) return false;//防呆
        tileSize = Mathf.Max(renderer.bounds.size.x, renderer.bounds.size.z);
        return true;
    }
    // 對齊格子:把 cellSize 對齊成 tile 的整數倍
    public static float SnapCellSizeToTile(float cellSize, float tileSize)
    {
        if (tileSize <= 0f) return cellSize;//防呆
        float factor = Mathf.Max(1f, Mathf.Round(cellSize / tileSize));//求平均值
        return factor * tileSize;//總長度
    }

    public static void GenerateMazeInEditor(MazeTab tab) //抓取MazeTab的資料
    {

        if (!TryGetPrefabMetrics(tab.wallPrefab, out float tileSize))
        {
            Debug.LogWarning("Prefab 沒有 Renderer，無法取得尺寸！");
            return;
        }
        //已取得tileSize後
        // 自動 snap：讓 cellSize = tileSize 的整數倍
        tab.cellSize = SnapCellSizeToTile(tab.cellSize, tileSize);

        Vector3 mazeOrigin = Vector3.zero;
        //terrain 除以 cellsize的等分
        if (tab.autoSizeFromTerrain && tab.terrain != null)
        {
            var size = tab.terrain.terrainData.size;
            tab.width = Mathf.Max(1, Mathf.FloorToInt(size.x / tab.cellSize));
            tab.height = Mathf.Max(1, Mathf.FloorToInt(size.z / tab.cellSize));
            mazeOrigin = tab.terrain.GetPosition();
        }
        else
        {
            mazeOrigin = Vector3.zero;
        }
        //沒有群組就新增一個新的
        if (tab.mazeParent == null)
        {
            GameObject root = new GameObject("MazeRoot");
            tab.mazeParent = root.transform;
        }
        if (tab.mazeParent.childCount > 0)
        {
            if (!EditorUtility.DisplayDialog("Clear Old Maze?", "Maze Parent 有子物件，是否刪除？", "Yes", "No"))
                return;
            ClearMaze(tab.mazeParent);
        }

        //DFS（Deep First Search）
        MazeCell[,] cells = InitCells(tab.width, tab.height);
        CarveFrom(0, 0, cells, tab.width, tab.height);
        BuildMazeWalls(tab, cells, mazeOrigin, tileSize);

        EditorUtility.SetDirty(tab.mazeParent.gameObject);
        SceneView.RepaintAll();

    }
    //建立棋盤格,全部封死,生成資料 所以不能void
    static MazeCell[,] InitCells(int width, int height)
    {
        MazeCell[,] cells = new MazeCell[width, height];
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                cells[x, y] = new MazeCell()
                {
                    visited = false,//格子有沒有走過
                    northWall = true,
                    southWall = true,
                    eastWall = true,
                    westWall = true
                };
            }
        }
        return cells;
    }
    //DFS（核心）挖洞、開路, 操作資料,使用void
    static void CarveFrom(int x, int y, MazeCell[,] cells, int width, int height)
    {
        cells[x, y].visited = true;
        List<Vector2Int> dirs = new()
        {
            new Vector2Int(0, 1),   // 上
            new Vector2Int(0, -1),  // 下
            new Vector2Int(1, 0),   // 右
            new Vector2Int(-1, 0)   // 左
        };
        Shuffle(dirs);//隨機上下左右
        foreach (var dir in dirs)
        {
            //計算下一格的位置
            int nx = x + dir.x;
            int ny = y + dir.y;
            //檢查是否越界
            if (nx < 0 || nx >= width || ny < 0 || ny >= height)
                continue;
            //DFS： 進入下一格＆打掉牆
            if (!cells[nx, ny].visited)
            {
                RemoveWallBetween(x, y, nx, ny, cells);//打掉牆
                //呼叫自己 遞迴（Recursion）
                CarveFrom(nx, ny, cells, width, height);//進入下一格
            }
        }
    }

    //隨機Fisher–Yates Shuffle
    static void Shuffle(List<Vector2Int> list)
    {
        for (int i = 0; i < list.Count; i++)
        {
            int j = Random.Range(i, list.Count);
            //把位置 i 的值與位置 j 的值對調
            (list[i], list[j]) = (list[j], list[i]);

        }
    }
    //打掉牆
    static void RemoveWallBetween(int x, int y, int nx, int ny, MazeCell[,] cells)
    {
        //判斷下一格在哪個方向
        if (ny == y + 1)
        {
            cells[x, y].northWall = false;
            cells[nx, ny].southWall = false;
        }
        else if (ny == y - 1)
        {
            cells[x, y].southWall = false;
            cells[nx, ny].northWall = false;
        }
        else if (nx == x + 1)
        {
            cells[x, y].eastWall = false;
            cells[nx, ny].westWall = false;
        }
        else if (nx == x - 1)
        {
            cells[x, y].westWall = false;
            cells[nx, ny].eastWall = false;
        }

    }
    //把資料變成真正的 3D 牆
    static void BuildMazeWalls(MazeTab tab, MazeCell[,] cells, Vector3 mazeOrigin, float tileSize)
    {
        for (int x = 0; x < tab.width; x++)
        {
            for (int y = 0; y < tab.height; y++)
            {
                Vector3 cellCenter = mazeOrigin + new Vector3(
                    (x + 0.5f) * tab.cellSize,
                    0f,
                    (y + 0.5f) * tab.cellSize
                );

                // pivot 在底部，所以直接用 mazeOrigin.y 當牆高度
                float wallY = mazeOrigin.y;

                var cell = cells[x, y];

                if (cell.northWall)
                    CreateWallStrip(tab, cellCenter, Vector3.right, Vector3.forward, wallY, tileSize, 0f + tab.extraRotationY);

                if (cell.eastWall)
                    CreateWallStrip(tab, cellCenter, Vector3.forward, Vector3.right, wallY, tileSize, 90f + tab.extraRotationY);

                if (y == 0 && cell.southWall)
                    CreateWallStrip(tab, cellCenter, Vector3.right, Vector3.back, wallY, tileSize, 0f + tab.extraRotationY);

                if (x == 0 && cell.westWall)
                    CreateWallStrip(tab, cellCenter, Vector3.forward, Vector3.left, wallY, tileSize, 90f + tab.extraRotationY);
            }
        }
    }

    // 3D實體牆
    private static void CreateWallStrip
    (MazeTab tab, Vector3 cellCenter, Vector3 alongDir, Vector3 normalDir, float wallY, float tileSize, float rotationY = 0f)
    {
        float tile = tileSize * Mathf.Max(0.0001f, tab.extraScale);

        // 防呆：overlap ~ tile 的 90% ，clamp超過就是tile的90%寬
        float clampedOverlap = Mathf.Clamp(tab.overlap, 0f, tile * 0.9f);

        // 每一塊牆實際佔據的有效寬度,max為防呆
        float effectiveTile = Mathf.Max(0.0001f, tile - clampedOverlap);

        // 需要幾塊才能覆蓋整個 cellSize（寧可多一點點）
        int segmentCount = Mathf.Max(1, Mathf.CeilToInt(tab.cellSize / effectiveTile));

        for (int i = 0; i < segmentCount; i++)
        {
            // 第一塊中心在左側：-cellSize(總長度)/2 + tile/2
            float offset = -tab.cellSize * 0.5f + tile * 0.5f + i * effectiveTile;
            // 之後每塊往 alongDir 方向移動 effectiveTile
            Vector3 pos = cellCenter
                          + alongDir * offset
                          + normalDir * (tab.cellSize * 0.5f);

            pos.y = wallY;

            GameObject wall = (GameObject)PrefabUtility.InstantiatePrefab(tab.wallPrefab, tab.mazeParent);
            wall.transform.position = pos;
            wall.transform.rotation = Quaternion.Euler(0f, rotationY, 0f);
            // 真正把牆放大 / 縮小
            wall.transform.localScale = Vector3.one * tab.extraScale;

            // 確保每個牆都有標記
            var marker = wall.GetComponent<MazeWallMarker>();
            if (marker == null)
                marker = wall.AddComponent<MazeWallMarker>();

            marker.normal = normalDir.normalized;   // ★ 這一行很重要
        }
    }


    public static void ClearMaze(Transform mazeParent)
    {
        if (mazeParent == null) return;

        for (int i = mazeParent.childCount - 1; i >= 0; i--)
        {
            Object.DestroyImmediate(mazeParent.GetChild(i).gameObject);
        }
    }
}
#endif