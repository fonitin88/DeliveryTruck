#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GridMazeEditorWindow : EditorWindow
{
    [Header("Maze Size")]
    public int width = 10;
    public int height = 10;
    [Header("Cell settings")]
    public float cellSize = 4f;
    [Header("Wall settings")]
    public GameObject wallPrefab;
    public float overlap = 0.01f;
    public float extraRotationY = 0f;
    public float extraScale = 1f;
    [Header("Group")]
    public Transform mazeParent;
    [Header("Terrain")]
    public Terrain terrain;
    public bool autoSizeFromTerrain = true;
    //內部
    private struct MazeCell
    {
        //格子的內容 演算法開始前不需要給預設值 所以預設是false
        public bool visited;
        public bool northWall;
        public bool southWall;
        public bool eastWall;
        public bool westWall;
    }
    private MazeCell[,] cells;//陣列座標
    private Vector3 mazeOrigin = Vector3.zero; //迷宮的放置位置從000開始
    private float tileSize = 1f;           // 由 prefab 自動取得

    [MenuItem("Tools/Maze Generator")]
    public static void ShowWindow()
    {
        GetWindow<GridMazeEditorWindow>("Maze Generator");
    }
    private void OnGUI()
    {
        cellSize = EditorGUILayout.FloatField("Maze Width", cellSize);
        //wall prefab
        EditorGUILayout.Space();
        wallPrefab = (GameObject)EditorGUILayout.ObjectField("Wall Prefab", wallPrefab, typeof(GameObject), false);
        extraRotationY = EditorGUILayout.FloatField("RotationY", extraRotationY);
        extraScale = EditorGUILayout.FloatField("Scale", extraScale);
        overlap = EditorGUILayout.FloatField("Overlap", overlap);
        EditorGUILayout.Space();
        terrain = (Terrain)EditorGUILayout.ObjectField("Terrain", terrain, typeof(Terrain), true);
        autoSizeFromTerrain = EditorGUILayout.Toggle("Auto Size From Terrain", autoSizeFromTerrain);
        if (autoSizeFromTerrain && terrain != null && wallPrefab != null)
        {
            if (TryGetPrefabMetrics(out float previewTile))
            {
                float snapped = SnapCellSizeToTile(cellSize, previewTile);
                var size = terrain.terrainData.size;

                int previewW = Mathf.Max(1, Mathf.FloorToInt(size.x / snapped));
                int previewH = Mathf.Max(1, Mathf.FloorToInt(size.z / snapped));

                EditorGUILayout.LabelField($"Preview Width : {previewW}");
                EditorGUILayout.LabelField($"Preview Height: {previewH}");
            }
        }
        else
        {
            width = EditorGUILayout.IntField("Width", width);
            height = EditorGUILayout.IntField("Height", height);
        }

        EditorGUILayout.Space();
        mazeParent = (Transform)EditorGUILayout.ObjectField("Group", mazeParent, typeof(Transform), true);

        EditorGUILayout.Space();
        using (new EditorGUI.DisabledScope(wallPrefab == null))
        {
            if (GUILayout.Button("Generate Maze"))
            {
                GenerateMazeInEditor();
            }
        }

        if (GUILayout.Button("Clear Maze"))
        {
            ClearMaze();
        }
    }

    // 從 Prefab 抓實際尺寸
    bool TryGetPrefabMetrics(out float tileSize)
    {
        tileSize = 1f;//一定要有一個值
        if (wallPrefab == null) return false;//防呆
        var renderer = wallPrefab.GetComponentInChildren<Renderer>();
        if (renderer == null) return false;//防呆
        tileSize = Mathf.Max(renderer.bounds.size.x, renderer.bounds.size.z);
        return true;
    }
    // 把 cellSize 對齊成 tile 的整數倍
    float SnapCellSizeToTile(float cellSize, float tileSize)
    {
        if (tileSize <= 0f) return cellSize;//防呆
        float factor = Mathf.Max(1f, Mathf.Round(cellSize / tileSize));//求平均值
        return factor * tileSize;//總長度
    }

    void GenerateMazeInEditor()
    {
        if (!TryGetPrefabMetrics(out tileSize))
        {
            Debug.LogWarning("Prefab 沒有 Renderer，無法取得尺寸！");
            return;
        }
        //已取得tileSize後
        // 自動 snap：讓 cellSize = tileSize 的整數倍
        cellSize = SnapCellSizeToTile(cellSize, tileSize);

        //terrain 除以 cellsize的等分
        if (autoSizeFromTerrain && terrain != null)
        {
            var size = terrain.terrainData.size;
            width = Mathf.Max(1, Mathf.FloorToInt(size.x / cellSize));
            height = Mathf.Max(1, Mathf.FloorToInt(size.z / cellSize));
            mazeOrigin = terrain.GetPosition();
        }
        else
        {
            mazeOrigin = Vector3.zero;
        }
        //沒有群組就新增一個新的
        if (mazeParent == null)
        {
            GameObject root = new GameObject("MazeRoot");
            mazeParent = root.transform;
        }
        if (mazeParent.childCount > 0)
        {
            if (!EditorUtility.DisplayDialog("Clear Old Maze?", "Maze Parent 有子物件，是否刪除？", "Yes", "No"))
                return;
            ClearMaze();
        }

        //DFS（Deep First Search）
        InitCells();
        CarveFrom(0, 0);
        BuildMazeWalls();

        EditorUtility.SetDirty(mazeParent.gameObject);
        SceneView.RepaintAll();

    }
    //建立棋盤格,全部封死
    void InitCells()
    {
        cells = new MazeCell[width, height];
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
    }
    //DFS（核心）挖洞、開路
    void CarveFrom(int x, int y)
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
                RemoveWallBetween(x, y, nx, ny);//打掉牆
                //呼叫自己 遞迴（Recursion）
                CarveFrom(nx, ny);//進入下一格
            }
        }
    }

    //隨機Fisher–Yates Shuffle
    void Shuffle(List<Vector2Int> list)
    {
        for (int i = 0; i < list.Count; i++)
        {
            int j = Random.Range(i, list.Count);
            //把位置 i 的值與位置 j 的值對調
            (list[i], list[j]) = (list[j], list[i]);

        }
    }
    //打掉牆
    void RemoveWallBetween(int x, int y, int nx, int ny)
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
    void BuildMazeWalls()
    {
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                Vector3 cellCenter = mazeOrigin + new Vector3(
                    (x + 0.5f) * cellSize,
                    0f,
                    (y + 0.5f) * cellSize
                );

                // pivot 在底部，所以直接用 mazeOrigin.y 當牆高度
                float wallY = mazeOrigin.y;

                var cell = cells[x, y];

                if (cell.northWall)
                    CreateWallStrip(cellCenter, Vector3.right, Vector3.forward, wallY, 0f + extraRotationY);

                if (cell.eastWall)
                    CreateWallStrip(cellCenter, Vector3.forward, Vector3.right, wallY, 90f + extraRotationY);

                if (y == 0 && cell.southWall)
                    CreateWallStrip(cellCenter, Vector3.right, Vector3.back, wallY, 0f + extraRotationY);

                if (x == 0 && cell.westWall)
                    CreateWallStrip(cellCenter, Vector3.forward, Vector3.left, wallY, 90f + extraRotationY);
            }
        }
    }

    /// 用「每塊牆有效寬度 = tileSize - overlap」來算數量與位置
    private void CreateWallStrip(Vector3 cellCenter, Vector3 alongDir, Vector3 normalDir, float wallY, float rotationY = 0f)
    {
        float tile = tileSize * Mathf.Max(0.0001f, extraScale);

        // 防呆：overlap 不要超過 tile 的 90%
        float clampedOverlap = Mathf.Clamp(overlap, 0f, tile * 0.9f);

        // 每一塊牆實際佔據的有效寬度（算 spacing 用）
        float effectiveTile = Mathf.Max(0.0001f, tile - clampedOverlap);

        // 需要幾塊才能覆蓋整個 cellSize（寧可多一點點）
        int segmentCount = Mathf.Max(1, Mathf.CeilToInt(cellSize / effectiveTile));

        for (int i = 0; i < segmentCount; i++)
        {
            // 第一塊中心在左側：-cellSize/2 + tile/2
            // 之後每塊往 alongDir 方向移動 effectiveTile
            float offset = -cellSize * 0.5f + tile * 0.5f + i * effectiveTile;

            Vector3 pos = cellCenter
                          + alongDir * offset
                          + normalDir * (cellSize * 0.5f);

            pos.y = wallY;

            GameObject wall = (GameObject)PrefabUtility.InstantiatePrefab(wallPrefab, mazeParent);
            wall.transform.position = pos;
            wall.transform.rotation = Quaternion.Euler(0f, rotationY, 0f);
            // 真正把牆放大 / 縮小
            wall.transform.localScale = Vector3.one * extraScale;
        }
    }


    void ClearMaze()
    {
        if (mazeParent == null) return;

        for (int i = mazeParent.childCount - 1; i >= 0; i--)
        {
            DestroyImmediate(mazeParent.GetChild(i).gameObject);
        }
    }
}
#endif
