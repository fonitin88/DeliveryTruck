using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class EnvTools
{
    List<GameObject> prefabsToSpawn = new List<GameObject>();
    List<GameObject> newPrefab = new List<GameObject>();
    GameObject groundObject;
    GameObject parentGroupObject;

    // 用字典管理 XYZ 軸的旋轉範圍（每個軸用 Vector2Int 表示 min/max）
    Dictionary<string, Vector2Int> rotationRanges = new Dictionary<string, Vector2Int>()
    {
        {"X",new Vector2Int(0,0)},
        {"Y",new Vector2Int(0,0)},
        {"Z",new Vector2Int(0,0)}
    };

    int spawnAmount = 1;
    float randomScaleMin = 1f;
    float randomScaleMax = 3f;
    float minDistanceBetweenObjects = 1f;

    bool alignToSurfaceNormal = true;

    public void Draw()
    {
        DrawPrefabList("Prefabs to Spawn:", prefabsToSpawn);

        spawnAmount = Mathf.Max(1, EditorGUILayout.IntField("Spawn Amount:", spawnAmount));

        //新增 RGBA 
        EditorGUILayout.LabelField("Ground Object:", EditorStyles.boldLabel);
        groundObject = (GameObject)EditorGUILayout.ObjectField(groundObject, typeof(GameObject), true);

        EditorGUILayout.Space();
        EditorGUILayout.Toggle("Align To Surface Normal", alignToSurfaceNormal);

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Rotation Range", EditorStyles.boldLabel);
        rotationRanges["X"] = DrawIntMinMaxSlider("X", rotationRanges["X"], -360, 360);
        rotationRanges["Y"] = DrawIntMinMaxSlider("Y", rotationRanges["Y"], -360, 360);
        rotationRanges["Z"] = DrawIntMinMaxSlider("Z", rotationRanges["Z"], -360, 360);

        EditorGUILayout.Space();
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Min Scale:", GUILayout.Width(70));
        randomScaleMin = EditorGUILayout.FloatField(randomScaleMin);

        EditorGUILayout.LabelField("Max Scale:", GUILayout.Width(70));
        randomScaleMax = EditorGUILayout.FloatField(randomScaleMax);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();
        minDistanceBetweenObjects = EditorGUILayout.FloatField("Spacing:沒效果", minDistanceBetweenObjects);

        if (GUILayout.Button("Spawn Randomly"))
        {
            SpawnPrefabs();
        }
    }

    Vector2Int DrawIntMinMaxSlider(string label, Vector2Int range, int minLimit, int maxLimit)
    {

        EditorGUILayout.LabelField(label, EditorStyles.boldLabel);

        float minF = range.x;
        float maxF = range.y;
        EditorGUILayout.MinMaxSlider(ref minF, ref maxF, minLimit, maxLimit);

        EditorGUILayout.BeginHorizontal();
        range.x = EditorGUILayout.IntField("Min", Mathf.RoundToInt(minF));
        GUILayout.FlexibleSpace();
        range.y = EditorGUILayout.IntField("Max", Mathf.RoundToInt(maxF));
        EditorGUILayout.EndHorizontal();

        //限制在允許範圍之內
        range.x = Mathf.Clamp(range.x, minLimit, maxLimit);
        range.y = Mathf.Clamp(range.y, minLimit, maxLimit);
        if (range.x > range.y)
        {
            range.x = range.y;
        }
        ;

        return range;
    }

    void DrawPrefabList(string label, List<GameObject> list)
    {
        EditorGUILayout.LabelField(label, EditorStyles.boldLabel);
        int newCount = Mathf.Max(1, EditorGUILayout.IntField("Prefab Count", list.Count));
        while (newCount > list.Count)
            list.Add(null);
        while (newCount < list.Count)
            list.RemoveAt(list.Count - 1);

        for (int i = 0; i < list.Count; i++)
        {
            list[i] = (GameObject)EditorGUILayout.ObjectField($"Prefab {i + 1}", list[i], typeof(GameObject), false);
        }
    }

    void SpawnPrefabs()
    {
        if (groundObject == null)
        {
            Debug.Log("請指定 Ground 物件");
        }
        //meshCol 就是指 地面的meshcollider
        MeshCollider meshCol = groundObject.GetComponent<MeshCollider>();
        if (meshCol == null)
        {
            Debug.Log("Ground 物件需要有 MeshCollider");
            return;
        }

        Bounds bounds = meshCol.bounds;

        // 建立一個空物件當作群組容器
        parentGroupObject = new GameObject("SpawnGroup");
        Undo.RegisterCreatedObjectUndo(parentGroupObject, "Create Group");

        //生成的位置
        List<Vector3> spawnedPositions = new List<Vector3>();

        //生成數量
        for (int i = 0; i < spawnAmount; i++)
        {
            if (TryGetValidPosition(meshCol, bounds, spawnedPositions, minDistanceBetweenObjects, out RaycastHit hit))
            {
                GameObject prefab = prefabsToSpawn[Random.Range(0, prefabsToSpawn.Count)];
                if (prefab)
                {
                    SpawnObjectAt(prefab, hit);
                    spawnedPositions.Add(hit.point);
                }
            }
        }
        // spawn後 自動選擇那個group
        Selection.activeGameObject = parentGroupObject;

    }

    // 嘗試在指定的範圍 (bounds) 內，找到一個符合條件的位置
    bool TryGetValidPosition(MeshCollider meshCol, Bounds bounds, List<Vector3> existingPositions, float minDistance, out RaycastHit result)
    {
        //地面範圍內隨機挑一個,發射 Raycast
        float randX = Random.Range(bounds.min.x, bounds.max.x);
        float randZ = Random.Range(bounds.min.z, bounds.max.z);
        Vector3 rayStart = new Vector3(randX, bounds.max.y + 10f, randZ);

        if (Physics.Raycast(rayStart, Vector3.down, out RaycastHit hit, Mathf.Infinity))
        {
            //射線打到的物件，是不是我指定的那個 MeshCollider
            if (hit.collider == meshCol)
            {
                Vector3 testPos = hit.point;

                bool isTooClose = false;
                //這段是檢查位置
                foreach (var pos in existingPositions)
                {
                    //太近 就跳過
                    if (Vector3.Distance(pos, testPos) < minDistance)
                    {
                        isTooClose = true;
                        break;
                    }
                }

                if (!isTooClose)
                {
                    result = hit;
                    return true;
                }
            }
        }
        result = default;
        return false;
    }
    void SpawnObjectAt(GameObject prefab, RaycastHit hit)
    {

        GameObject newObj = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        newObj.transform.position = hit.point;

        //  貼合法線
        if (alignToSurfaceNormal)
            newObj.transform.up = hit.normal;

        // --- 隨機旋轉 ---
        int rotX = Random.Range(rotationRanges["X"].x, rotationRanges["X"].y);
        int rotY = Random.Range(rotationRanges["Y"].x, rotationRanges["Y"].y);
        int rotZ = Random.Range(rotationRanges["Z"].x, rotationRanges["Z"].y);
        // 基於原本的值+上random
        newObj.transform.Rotate(rotX, rotY, rotZ, Space.Self);

        // --- 隨機縮放 ---
        float randomScale = Random.Range(randomScaleMin, randomScaleMax);
        newObj.transform.localScale *= randomScale;

        // --- 加入群組 ---
        newObj.transform.SetParent(parentGroupObject.transform, true);
        Undo.RegisterCreatedObjectUndo(newObj, "Spawn Prefab");
        newPrefab.Add(newObj);

        // 即時更新
        EditorUtility.SetDirty(newObj);
        SceneView.RepaintAll();
    }
}
