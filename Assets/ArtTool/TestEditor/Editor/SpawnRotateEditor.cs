using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class SpawnRotateEditor
{
    List<GameObject> prefabs = new List<GameObject>();
    GameObject areaObject;
    List<GameObject> spawnedList = new List<GameObject>();

    int spawnCount = 10;

    Vector2Int rotXRange = new Vector2Int(0, 0);
    Vector2Int rotYRange = new Vector2Int(0, 360);
    Vector2Int rotZRange = new Vector2Int(0, 0);

    bool alignToNormal = true;

    public void Draw()
    {
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Spawn Prefabs", EditorStyles.boldLabel);

        // Prefab List
        int newCount = Mathf.Max(1, EditorGUILayout.IntField("Prefab Count", prefabs.Count == 0 ? 1 : prefabs.Count));
        while (prefabs.Count < newCount) prefabs.Add(null);
        while (prefabs.Count > newCount) prefabs.RemoveAt(prefabs.Count - 1);

        for (int i = 0; i < prefabs.Count; i++)
            prefabs[i] = (GameObject)EditorGUILayout.ObjectField($"Prefab {i + 1}", prefabs[i], typeof(GameObject), false);

        EditorGUILayout.Space();
        spawnCount = EditorGUILayout.IntSlider("Total Spawn Count", spawnCount, 1, 200);
        areaObject = (GameObject)EditorGUILayout.ObjectField("Spawn Area (MeshCollider)", areaObject, typeof(GameObject), true);

        EditorGUILayout.Space();
        DrawRotationRange("Rotation Range", ref rotXRange, ref rotYRange, ref rotZRange);
        alignToNormal = EditorGUILayout.Toggle("Align To Surface Normal", alignToNormal);

        EditorGUILayout.Space();
        if (GUILayout.Button("Spawn"))
        {
            ClearList(spawnedList);
            SpawnAll(prefabs, spawnCount, spawnedList, rotXRange, rotYRange, rotZRange, areaObject, alignToNormal);
        }

        if (GUILayout.Button("Clear Spawned"))
            ClearList(spawnedList);
    }

    void DrawRotationRange(string label, ref Vector2Int xRange, ref Vector2Int yRange, ref Vector2Int zRange)
    {
        EditorGUILayout.LabelField(label, EditorStyles.boldLabel);
        xRange = DrawIntMinMaxSlider("Rotate X Range", xRange, 0, 360);
        yRange = DrawIntMinMaxSlider("Rotate Y Range", yRange, 0, 360);
        zRange = DrawIntMinMaxSlider("Rotate Z Range", zRange, 0, 360);
    }

    Vector2Int DrawIntMinMaxSlider(string label, Vector2Int range, int minLimit, int maxLimit)
    {
        EditorGUILayout.Space(3);
        EditorGUILayout.LabelField(label, EditorStyles.boldLabel);

        // Slider
        float minF = range.x;
        float maxF = range.y;
        EditorGUILayout.MinMaxSlider(ref minF, ref maxF, minLimit, maxLimit);

        // ✅ 顯示整數輸入框（分成左右）
        EditorGUILayout.BeginHorizontal();
        range.x = EditorGUILayout.IntField("Min", Mathf.RoundToInt(minF));
        GUILayout.FlexibleSpace();
        range.y = EditorGUILayout.IntField("Max", Mathf.RoundToInt(maxF));
        EditorGUILayout.EndHorizontal();

        // 限制範圍
        range.x = Mathf.Clamp(range.x, minLimit, maxLimit);
        range.y = Mathf.Clamp(range.y, minLimit, maxLimit);
        if (range.x > range.y) range.x = range.y;

        return range;
    }

    void SpawnAll(List<GameObject> prefabs, int count, List<GameObject> list,
                  Vector2Int xRange, Vector2Int yRange, Vector2Int zRange,
                  GameObject areaObj, bool alignNormal)
    {
        if (prefabs == null || prefabs.Count == 0)
        {
            Debug.LogWarning("⚠️ 沒有指定 Prefab。");
            return;
        }

        if (areaObj == null)
        {
            Debug.LogWarning("⚠️ 未指定 MeshCollider 物件。");
            return;
        }

        MeshCollider meshCol = areaObj.GetComponent<MeshCollider>();
        if (meshCol == null)
        {
            Debug.LogWarning("⚠️ 指定物件沒有 MeshCollider。");
            return;
        }

        Bounds bounds = meshCol.bounds;

        // ✅ 自動建立群組
        GameObject group = new GameObject($"SpawnGroup_{System.DateTime.Now:HHmmss}");
        Undo.RegisterCreatedObjectUndo(group, "Create Spawn Group");

        for (int i = 0; i < count; i++)
        {
            GameObject selectedPrefab = prefabs[Random.Range(0, prefabs.Count)];
            if (selectedPrefab == null) continue;

            Vector3 rayStart = new Vector3(
                Random.Range(bounds.min.x, bounds.max.x),
                bounds.max.y + 10f,
                Random.Range(bounds.min.z, bounds.max.z)
            );

            if (Physics.Raycast(rayStart, Vector3.down, out RaycastHit hit, Mathf.Infinity))
            {
                if (hit.collider == meshCol)
                {
                    GameObject obj = (GameObject)PrefabUtility.InstantiatePrefab(selectedPrefab);
                    obj.transform.position = hit.point;

                    if (alignNormal)
                        obj.transform.up = hit.normal;

                    int rotX = Random.Range(xRange.x, xRange.y + 1);
                    int rotY = Random.Range(yRange.x, yRange.y + 1);
                    int rotZ = Random.Range(zRange.x, zRange.y + 1);
                    obj.transform.Rotate(rotX, rotY, rotZ, Space.Self);

                    obj.transform.SetParent(group.transform);
                    list.Add(obj);
                }
            }
        }

        Debug.Log($"✅ 已生成 {list.Count} 個物件（{prefabs.Count} 種）於 MeshCollider 範圍內。");
    }

    void ClearList(List<GameObject> list)
    {
        foreach (var obj in list)
        {
            if (obj != null)
                Object.DestroyImmediate(obj);
        }
        list.Clear();
    }
}
