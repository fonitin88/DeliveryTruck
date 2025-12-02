#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

public class MazeTab
{
    //Maze Size
    public int width = 10;
    public int height = 10;
    //Cell settings
    public float cellSize = 4f;
    ///Wall settings
    public GameObject wallPrefab;
    public float overlap = 0.01f;
    public float extraRotationY = 0f;
    public float extraScale = 1f;
    ///Group
    public Transform mazeParent;

    public Terrain terrain;
    public bool autoSizeFromTerrain = true;

    public void DrawGUI()
    {
        cellSize = EditorGUILayout.FloatField("Maze Width", cellSize);
        EditorGUILayout.Space();

        //wall prefab
        wallPrefab = (GameObject)EditorGUILayout.ObjectField("Wall Prefab", wallPrefab, typeof(GameObject), false);
        extraRotationY = EditorGUILayout.FloatField("RotationY", extraRotationY);
        extraScale = EditorGUILayout.FloatField("Scale", extraScale);
        overlap = EditorGUILayout.FloatField("Overlap", overlap);
        EditorGUILayout.Space();
        terrain = (Terrain)EditorGUILayout.ObjectField("Terrain", terrain, typeof(Terrain), true);
        autoSizeFromTerrain = EditorGUILayout.Toggle("Auto Size From Terrain", autoSizeFromTerrain);

        if (autoSizeFromTerrain && terrain != null && wallPrefab != null)
        {
            if (Maze.TryGetPrefabMetrics(wallPrefab, out float previewTile))
            {
                float snapped = Maze.SnapCellSizeToTile(cellSize, previewTile);
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
                Maze.GenerateMazeInEditor(this); // 👉 呼叫邏輯層
            }
        }

        if (GUILayout.Button("Clear Maze"))
        {
            Maze.ClearMaze(mazeParent); // 👉 呼叫邏輯層
        }
    }

}
#endif